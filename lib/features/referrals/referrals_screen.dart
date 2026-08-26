import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/referrals/referral_models.dart';
import '../../core/referrals/referral_service.dart';
import '../../design_system/strot_tokens.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key, required this.service, this.initialLeadId});
  final ReferralService service;
  final String? initialLeadId;
  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  late Future<ReferralWorkspaceRecord> future = widget.service.loadWorkspace();
  void reload() => setState(() {
    future = widget.service.loadWorkspace();
  });
  @override
  Widget build(BuildContext context) => Material(
    color: StrotColors.cream,
    child: FutureBuilder<ReferralWorkspaceRecord>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _Failure(
            message: snapshot.error is ApiException
                ? (snapshot.error! as ApiException).message
                : 'Referral operations are temporarily unavailable.',
            retry: reload,
          );
        }
        final record = snapshot.requireData,
            partner = [
              'service_partner',
              'api_provider',
            ].contains(record.context.accountType);
        if (widget.initialLeadId != null) {
          final lead = record.leads
              .where((item) => item.id == widget.initialLeadId)
              .firstOrNull;
          if (lead != null) return _ExactLead(item: lead);
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return ListView(
              padding: const EdgeInsets.all(StrotSpacing.lg),
              children: [
                Text(
                  record.context.programme.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: StrotColors.gold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: StrotSpacing.sm),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: StrotSpacing.md,
                  children: [
                    SizedBox(
                      width: wide
                          ? 620
                          : constraints.maxWidth - StrotSpacing.lg * 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Referral workspace',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: StrotSpacing.sm),
                          Text(record.context.programme.description),
                        ],
                      ),
                    ),
                    _Code(code: record.context.referralCode),
                  ],
                ),
                const SizedBox(height: StrotSpacing.lg),
                GridView.count(
                  crossAxisCount: wide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: StrotSpacing.md,
                  mainAxisSpacing: StrotSpacing.md,
                  childAspectRatio: wide ? 1.8 : 1.35,
                  children: [
                    _Metric(
                      label: 'Eligible services',
                      value: '${record.services.length}',
                    ),
                    _Metric(
                      label: 'Referrals',
                      value: '${record.analytics.referrals}',
                    ),
                    _Metric(
                      label: 'Qualified',
                      value: '${record.analytics.qualified}',
                    ),
                    _Metric(
                      label: 'Available',
                      value: _money(record.wallet.availableMinor),
                    ),
                  ],
                ),
                if (partner) ...[
                  const SizedBox(height: StrotSpacing.md),
                  _Notice(
                    text:
                        '${record.eligibilityNotice} Own services and related service families are never offered or accepted.',
                  ),
                ],
                const SizedBox(height: StrotSpacing.lg),
                Wrap(
                  spacing: StrotSpacing.md,
                  runSpacing: StrotSpacing.md,
                  children: [
                    ElevatedButton.icon(
                      key: const Key('referral-introduce'),
                      onPressed: record.services.isEmpty
                          ? null
                          : () => _introduce(context, record.services),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Introduce opportunity'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _createLink(context),
                      icon: const Icon(Icons.link_outlined),
                      label: const Text('Create share link'),
                    ),
                    OutlinedButton.icon(
                      key: const Key('referral-withdraw'),
                      onPressed:
                          record.context.kycStatus == 'verified' &&
                              record.wallet.availableMinor >= 100
                          ? () => _withdraw(context, record.wallet)
                          : null,
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: const Text('Request withdrawal'),
                    ),
                  ],
                ),
                if (record.context.kycStatus != 'verified') ...[
                  const SizedBox(height: StrotSpacing.sm),
                  const Text(
                    'Verified KYC is required before withdrawal. Verification remains governed by STROT and private S3 records.',
                    style: TextStyle(color: StrotColors.charcoalMuted),
                  ),
                ],
                const SizedBox(height: StrotSpacing.xl),
                _Section(
                  title: 'Referral history',
                  child: record.leads.isEmpty
                      ? const _Empty(text: 'No referrals have been recorded.')
                      : Column(
                          children: record.leads
                              .map((item) => _LeadTile(item: item))
                              .toList(),
                        ),
                ),
                const SizedBox(height: StrotSpacing.lg),
                Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: wide ? FlexFit.tight : FlexFit.loose,
                      child: _Section(
                        title: 'Share links',
                        child: record.links.isEmpty
                            ? const _Empty(text: 'No share links yet.')
                            : Column(
                                children: record.links
                                    .map(
                                      (item) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          item.shareUrl,
                                          style: const TextStyle(
                                            color: StrotColors.gold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${item.visits} visits · ${item.expiresAt == null ? 'No expiry' : 'Expiring link'}',
                                        ),
                                        trailing: const Icon(
                                          Icons.open_in_new_outlined,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ),
                    SizedBox(
                      width: wide ? StrotSpacing.lg : 0,
                      height: wide ? 0 : StrotSpacing.lg,
                    ),
                    Flexible(
                      fit: wide ? FlexFit.tight : FlexFit.loose,
                      child: _Section(
                        title: 'Approved campaigns',
                        child: record.campaigns.isEmpty
                            ? const _Empty(
                                text: 'No campaign applies to your programme.',
                              )
                            : Column(
                                children: record.campaigns
                                    .map(
                                      (item) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(item.name),
                                        subtitle: Text(
                                          '${item.description}\n${item.assetCount} approved S3 materials',
                                        ),
                                        isThreeLine: true,
                                        trailing: Chip(
                                          label: Text(item.status),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ),
  );

  Future<void> _introduce(
    BuildContext context,
    List<ReferralEligibleService> services,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _IntroductionForm(service: widget.service, services: services),
    );
    if (result == true) reload();
  }

  Future<void> _createLink(BuildContext context) async {
    try {
      await widget.service.createLink(landingPage: '/services');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Secure referral link created.')),
        );
        reload();
      }
    } on Object catch (error) {
      if (context.mounted) _showError(context, error);
    }
  }

  Future<void> _withdraw(
    BuildContext context,
    ReferralWalletRecord wallet,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WithdrawalForm(
        service: widget.service,
        availableMinor: wallet.availableMinor,
      ),
    );
    if (result == true) reload();
  }
}

class _IntroductionForm extends StatefulWidget {
  const _IntroductionForm({required this.service, required this.services});
  final ReferralService service;
  final List<ReferralEligibleService> services;
  @override
  State<_IntroductionForm> createState() => _IntroductionFormState();
}

class _IntroductionFormState extends State<_IntroductionForm> {
  final key = GlobalKey<FormState>(),
      name = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController(),
      relationship = TextEditingController(),
      note = TextEditingController();
  String? serviceId, error;
  bool saving = false;
  @override
  void dispose() {
    for (final item in [name, email, phone, relationship, note]) {
      item.dispose();
    }
    super.dispose();
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
              'Introduce an opportunity',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: StrotSpacing.sm),
            const Text(
              'STROT will request the prospect’s consent before progressing this introduction.',
            ),
            const SizedBox(height: StrotSpacing.md),
            TextFormField(
              key: const Key('referral-name'),
              controller: name,
              decoration: const InputDecoration(labelText: 'Prospect name'),
              validator: (value) => (value?.trim().length ?? 0) < 2
                  ? 'Enter the prospect name'
                  : null,
            ),
            const SizedBox(height: StrotSpacing.md),
            TextFormField(
              key: const Key('referral-email'),
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            const SizedBox(height: StrotSpacing.md),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            const SizedBox(height: StrotSpacing.md),
            DropdownButtonFormField<String>(
              key: const Key('referral-service'),
              initialValue: serviceId,
              decoration: const InputDecoration(labelText: 'Eligible service'),
              items: widget.services
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => serviceId = value,
              validator: (value) =>
                  value == null ? 'Select an eligible service' : null,
            ),
            const SizedBox(height: StrotSpacing.md),
            TextFormField(
              controller: relationship,
              decoration: const InputDecoration(
                labelText: 'Relationship (optional)',
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            TextFormField(
              controller: note,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Context (optional)',
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: StrotSpacing.md),
              _Notice(text: error!),
            ],
            const SizedBox(height: StrotSpacing.lg),
            ElevatedButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Recording…' : 'Send consent invitation'),
            ),
          ],
        ),
      ),
    ),
  );
  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    if (email.text.trim().isEmpty && phone.text.trim().isEmpty) {
      setState(() => error = 'Provide an email address or phone number.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.service.introduce(
        name: name.text.trim(),
        email: email.text.trim().isEmpty ? null : email.text.trim(),
        phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
        serviceId: serviceId!,
        relationship: relationship.text.trim().isEmpty
            ? null
            : relationship.text.trim(),
        note: note.text.trim().isEmpty ? null : note.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on Object catch (exception) {
      if (mounted) {
        setState(() {
          saving = false;
          error = exception is ApiException
              ? exception.message
              : 'The introduction could not be recorded.';
        });
      }
    }
  }
}

class _WithdrawalForm extends StatefulWidget {
  const _WithdrawalForm({required this.service, required this.availableMinor});
  final ReferralService service;
  final int availableMinor;
  @override
  State<_WithdrawalForm> createState() => _WithdrawalFormState();
}

class _WithdrawalFormState extends State<_WithdrawalForm> {
  final key = GlobalKey<FormState>(),
      amount = TextEditingController(),
      bank = TextEditingController(),
      accountName = TextEditingController(),
      accountNumber = TextEditingController();
  String method = 'strot_credit';
  bool saving = false;
  String? error;
  @override
  void dispose() {
    for (final item in [amount, bank, accountName, accountNumber]) {
      item.dispose();
    }
    super.dispose();
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
              'Request withdrawal',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              'Available ${_money(widget.availableMinor)}. Submission reserves funds for review and does not initiate a transfer.',
            ),
            const SizedBox(height: StrotSpacing.md),
            TextFormField(
              key: const Key('withdrawal-amount'),
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount (NGN)'),
              validator: (value) {
                final minor = ((double.tryParse(value ?? '') ?? 0) * 100)
                    .round();
                return minor < 100 || minor > widget.availableMinor
                    ? 'Enter an amount within the available balance'
                    : null;
              },
            ),
            const SizedBox(height: StrotSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: const InputDecoration(labelText: 'Method'),
              items: const [
                DropdownMenuItem(
                  value: 'strot_credit',
                  child: Text('STROT account credit'),
                ),
                DropdownMenuItem(
                  value: 'bank_transfer',
                  child: Text('Bank transfer'),
                ),
              ],
              onChanged: (value) => setState(() => method = value!),
            ),
            if (method == 'bank_transfer') ...[
              const SizedBox(height: StrotSpacing.md),
              TextFormField(
                controller: bank,
                decoration: const InputDecoration(labelText: 'Bank name'),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Enter the bank name' : null,
              ),
              const SizedBox(height: StrotSpacing.md),
              TextFormField(
                controller: accountName,
                decoration: const InputDecoration(labelText: 'Account name'),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Enter the account name' : null,
              ),
              const SizedBox(height: StrotSpacing.md),
              TextFormField(
                controller: accountNumber,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Account number'),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Enter the account number' : null,
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: StrotSpacing.md),
              _Notice(text: error!),
            ],
            const SizedBox(height: StrotSpacing.lg),
            ElevatedButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Submitting…' : 'Submit for review'),
            ),
          ],
        ),
      ),
    ),
  );
  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await widget.service.requestWithdrawal(
        amountMinor: (double.parse(amount.text) * 100).round(),
        method: method,
        destination: method == 'strot_credit'
            ? {'account': 'authenticated_client_account'}
            : {
                'bank_name': bank.text.trim(),
                'account_name': accountName.text.trim(),
                'account_number': accountNumber.text.trim(),
              },
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on Object catch (exception) {
      if (mounted) {
        setState(() {
          saving = false;
          error = exception is ApiException
              ? exception.message
              : 'The withdrawal could not be requested.';
        });
      }
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: StrotSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    ),
  );
}

class _Code extends StatelessWidget {
  const _Code({required this.code});
  final String code;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(StrotSpacing.md),
    decoration: BoxDecoration(border: Border.all(color: StrotColors.gold)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PERMANENT CODE', style: Theme.of(context).textTheme.labelSmall),
        Text(code, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const Divider(height: StrotSpacing.xl),
          child,
        ],
      ),
    ),
  );
}

class _LeadTile extends StatelessWidget {
  const _LeadTile({required this.item});
  final ReferralLeadRecord item;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(item.prospectName),
    subtitle: Text('${item.serviceInterest} · ${item.prospectContact}'),
    trailing: Chip(label: Text(item.status.replaceAll('_', ' '))),
  );
}

class _ExactLead extends StatelessWidget {
  const _ExactLead({required this.item});
  final ReferralLeadRecord item;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(StrotSpacing.lg),
    children: [
      TextButton.icon(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Referral workspace'),
      ),
      const SizedBox(height: StrotSpacing.md),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXACT REFERRAL RECORD',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: StrotColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: StrotSpacing.sm),
              Text(
                item.prospectName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: StrotSpacing.md),
              Text(item.serviceInterest),
              Text(item.prospectContact),
              const SizedBox(height: StrotSpacing.md),
              Chip(label: Text(item.status.replaceAll('_', ' '))),
            ],
          ),
        ),
      ),
    ],
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(StrotSpacing.md),
    decoration: BoxDecoration(
      color: StrotColors.goldMuted,
      border: Border(left: BorderSide(color: StrotColors.gold, width: 2)),
    ),
    child: Text(text),
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: StrotSpacing.lg),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(color: StrotColors.charcoalMuted),
      ),
    ),
  );
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: StrotSpacing.md),
          OutlinedButton(onPressed: retry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

String _money(int minor) => 'NGN ${(minor / 100).toStringAsFixed(2)}';
void _showError(BuildContext context, Object error) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error is ApiException
              ? error.message
              : 'The request could not be completed.',
        ),
      ),
    );
