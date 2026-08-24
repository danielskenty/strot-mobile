import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/partner/partner_payout_profile_service.dart';
import '../../core/profile/organization_profile_service.dart';
import '../../design_system/strot_tokens.dart';

class PartnerPayoutSettingsScreen extends StatefulWidget {
  const PartnerPayoutSettingsScreen({
    super.key,
    required this.service,
    required this.organizationService,
  });
  final PartnerPayoutProfileService service;
  final OrganizationProfileService organizationService;
  @override
  State<PartnerPayoutSettingsScreen> createState() =>
      _PartnerPayoutSettingsScreenState();
}

class _PartnerPayoutSettingsScreenState
    extends State<PartnerPayoutSettingsScreen> {
  late Future<List<PartnerPayoutProfile>> future = widget.service.list();
  void reload() => setState(() {
    future = widget.service.list();
  });

  @override
  Widget build(BuildContext context) => Material(
    color: StrotColors.cream,
    child: FutureBuilder<List<PartnerPayoutProfile>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final profiles = snapshot.requireData;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              'PARTNER FINANCE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: StrotColors.gold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              'Bank, tax and payout settings',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              'Maintain the verified destination STROT uses when reconciling approved partner payouts.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: StrotSpacing.lg),
            ...profiles.map((item) => _ProfileCard(item: item)),
            if (profiles.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(StrotSpacing.lg),
                  child: Text('No payout destination has been submitted.'),
                ),
              ),
            const SizedBox(height: StrotSpacing.md),
            ElevatedButton.icon(
              onPressed: () => _edit(context),
              icon: const Icon(Icons.lock_outline),
              label: Text(
                profiles.isEmpty
                    ? 'Submit payout details'
                    : 'Replace payout details',
              ),
            ),
            const SizedBox(height: StrotSpacing.lg),
            Container(
              padding: const EdgeInsets.all(StrotSpacing.md),
              decoration: BoxDecoration(
                color: StrotColors.goldMuted,
                border: Border.all(color: StrotColors.gold),
              ),
              child: const Text(
                'A recent two-factor confirmation is required. Saving details never initiates a transfer, and full account or tax identifiers are never returned.',
              ),
            ),
          ],
        );
      },
    ),
  );

  Future<void> _edit(BuildContext context) async {
    final organizations = (await widget.organizationService.list())
        .where((item) => item.type == 'partner')
        .toList();
    if (!context.mounted) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _PayoutForm(service: widget.service, organizations: organizations),
    );
    if (saved == true) reload();
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.item});
  final PartnerPayoutProfile item;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.organizationName ?? 'Partner organization',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: StrotColors.gold),
                    ),
                    Text(
                      item.beneficiaryName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              Chip(label: Text(item.status.replaceAll('_', ' '))),
            ],
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(item.bankName, style: Theme.of(context).textTheme.titleMedium),
          Text('${item.accountNumberMasked} · ${item.currency}'),
          if (item.taxIdentifierMasked != null)
            Text('Tax record · ${item.taxIdentifierMasked}'),
        ],
      ),
    ),
  );
}

class _PayoutForm extends StatefulWidget {
  const _PayoutForm({required this.service, required this.organizations});
  final PartnerPayoutProfileService service;
  final List<OrganizationProfileRecord> organizations;
  @override
  State<_PayoutForm> createState() => _PayoutFormState();
}

class _PayoutFormState extends State<_PayoutForm> {
  final key = GlobalKey<FormState>();
  final controllers = <String, TextEditingController>{
    'beneficiary': TextEditingController(),
    'bank': TextEditingController(),
    'account': TextEditingController(),
    'bankCode': TextEditingController(),
    'currency': TextEditingController(text: 'NGN'),
    'tax': TextEditingController(),
  };
  int? organizationId;
  String taxType = 'company';
  String? error;

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? optional(String name) {
    final value = controllers[name]!.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      StrotSpacing.lg,
      StrotSpacing.lg,
      StrotSpacing.lg,
      MediaQuery.viewInsetsOf(context).bottom + StrotSpacing.lg,
    ),
    child: Form(
      key: key,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Submit payout details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              'Confirm two-factor authentication in Account security before saving.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: StrotSpacing.md),
            DropdownButtonFormField<int>(
              key: const Key('payout-organization-select'),
              initialValue: organizationId,
              decoration: const InputDecoration(
                labelText: 'Partner organization',
              ),
              items: widget.organizations
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => organizationId = value,
              validator: (value) =>
                  value == null ? 'Select an organization' : null,
            ),
            for (final entry in [
              ('beneficiary', 'Beneficiary name'),
              ('bank', 'Bank name'),
              ('account', 'Account number'),
              ('bankCode', 'Bank code'),
              ('currency', 'Currency'),
              ('tax', 'Tax identifier'),
            ])
              Padding(
                padding: const EdgeInsets.only(top: StrotSpacing.md),
                child: TextFormField(
                  key: Key('payout-${entry.$1}'),
                  controller: controllers[entry.$1],
                  obscureText: entry.$1 == 'account' || entry.$1 == 'tax',
                  keyboardType: entry.$1 == 'account'
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(labelText: entry.$2),
                  validator:
                      [
                        'beneficiary',
                        'bank',
                        'account',
                        'currency',
                      ].contains(entry.$1)
                      ? (value) =>
                            (value?.trim().isEmpty ?? true) ? 'Required' : null
                      : null,
                ),
              ),
            const SizedBox(height: StrotSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: taxType,
              decoration: const InputDecoration(labelText: 'Tax type'),
              items: const [
                DropdownMenuItem(value: 'company', child: Text('Company')),
                DropdownMenuItem(
                  value: 'individual',
                  child: Text('Individual'),
                ),
              ],
              onChanged: (value) => taxType = value ?? 'company',
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: StrotSpacing.md),
                child: Text(
                  error!,
                  style: const TextStyle(
                    color: StrotColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: StrotSpacing.md),
            ElevatedButton(
              onPressed: widget.organizations.isEmpty ? null : _save,
              child: const Text('Save securely'),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _save() async {
    if (!(key.currentState?.validate() ?? false)) return;
    try {
      await widget.service.save(
        PartnerPayoutProfileInput(
          organizationId: organizationId!,
          beneficiaryName: controllers['beneficiary']!.text.trim(),
          bankName: controllers['bank']!.text.trim(),
          accountNumber: controllers['account']!.text.trim(),
          bankCode: optional('bankCode'),
          currency: controllers['currency']!.text.trim().toUpperCase(),
          taxType: taxType,
          taxIdentifier: optional('tax'),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (exception) {
      setState(
        () => error = exception.statusCode == 423
            ? 'Confirm two-factor authentication in Account security, then try again.'
            : exception.message,
      );
    }
  }
}
