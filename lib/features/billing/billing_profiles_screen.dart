import 'package:flutter/material.dart';
import '../../core/billing/billing_profile_models.dart';
import '../../core/billing/billing_profile_service.dart';
import '../../core/profile/organization_profile_service.dart';
import '../../design_system/strot_tokens.dart';

class BillingProfilesScreen extends StatefulWidget {
  const BillingProfilesScreen({
    super.key,
    required this.service,
    required this.organizationService,
  });
  final BillingProfileService service;
  final OrganizationProfileService organizationService;
  @override
  State<BillingProfilesScreen> createState() => _BillingProfilesScreenState();
}

class _BillingProfilesScreenState extends State<BillingProfilesScreen> {
  late Future<List<BillingProfileRecord>> future;
  @override
  void initState() {
    super.initState();
    future = widget.service.list();
  }

  void refresh() {
    setState(() {
      future = widget.service.list();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Billing details')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _add(context),
      icon: const Icon(Icons.add),
      label: const Text('Add profile'),
    ),
    body: FutureBuilder<List<BillingProfileRecord>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final profiles = snapshot.requireData;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'FINANCE SETTINGS',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              'Billing identity and addresses',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              'Your default record is selected for new invoices and payment instructions.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: StrotSpacing.lg),
            if (profiles.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(StrotSpacing.lg),
                  child: Text(
                    'No billing profile yet. Add the identity that should appear on your next invoice.',
                  ),
                ),
              ),
            ...profiles.map(
              (profile) => Card(
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
                                  profile.organizationName ?? 'Billing profile',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: StrotColors.gold),
                                ),
                                Text(
                                  profile.label,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              profile.isDefault ? 'Default' : 'Active',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: StrotSpacing.md),
                      Text(
                        profile.legalName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(profile.billingEmail),
                      const SizedBox(height: StrotSpacing.sm),
                      Text(profile.formattedAddress),
                      if (profile.taxIdentifier != null) ...[
                        const SizedBox(height: StrotSpacing.sm),
                        Text('Tax identifier · ${profile.taxIdentifier}'),
                      ],
                      if (!profile.isDefault) ...[
                        const Divider(height: StrotSpacing.xl),
                        OutlinedButton(
                          key: Key('archive-billing-${profile.id}'),
                          onPressed: () async {
                            await widget.service.archive(profile.id);
                            refresh();
                          },
                          child: const Text('Archive address'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  Future<void> _add(BuildContext context) async {
    final organizations = await widget.organizationService.list();
    if (!context.mounted) return;
    final formKey = GlobalKey<FormState>();
    final controllers = {
      for (final key in [
        'label',
        'legal',
        'email',
        'phone',
        'tax',
        'address1',
        'address2',
        'city',
        'state',
        'postal',
        'country',
      ])
        key: TextEditingController(text: key == 'country' ? 'NG' : ''),
    };
    int? organizationId;
    String identityType = 'company';
    bool isDefault = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            StrotSpacing.lg,
            StrotSpacing.lg,
            StrotSpacing.lg,
            MediaQuery.viewInsetsOf(context).bottom + StrotSpacing.lg,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add billing profile',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: StrotSpacing.md),
                  DropdownButtonFormField<int>(
                    key: const Key('billing-organization-select'),
                    initialValue: organizationId,
                    decoration: const InputDecoration(
                      labelText: 'Organization',
                    ),
                    items: organizations
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setModalState(() => organizationId = value),
                    validator: (value) =>
                        value == null ? 'Select an organization' : null,
                  ),
                  const SizedBox(height: StrotSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: identityType,
                    decoration: const InputDecoration(
                      labelText: 'Identity type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'company',
                        child: Text('Company'),
                      ),
                      DropdownMenuItem(
                        value: 'individual',
                        child: Text('Individual'),
                      ),
                    ],
                    onChanged: (value) => identityType = value ?? 'company',
                  ),
                  for (final entry in [
                    ('label', 'Label'),
                    ('legal', 'Legal billing name'),
                    ('email', 'Invoice email'),
                    ('phone', 'Billing phone'),
                    ('tax', 'Tax identifier'),
                    ('address1', 'Address line 1'),
                    ('address2', 'Address line 2'),
                    ('city', 'City'),
                    ('state', 'State / region'),
                    ('postal', 'Postal code'),
                    ('country', 'Country code'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(top: StrotSpacing.md),
                      child: TextFormField(
                        key: Key('billing-${entry.$1}'),
                        controller: controllers[entry.$1],
                        decoration: InputDecoration(labelText: entry.$2),
                        validator:
                            [
                              'label',
                              'legal',
                              'email',
                              'address1',
                              'city',
                              'country',
                            ].contains(entry.$1)
                            ? (value) => (value?.trim().isEmpty ?? true)
                                  ? 'Required'
                                  : null
                            : null,
                      ),
                    ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isDefault,
                    onChanged: (value) =>
                        setModalState(() => isDefault = value ?? false),
                    title: const Text('Use as default billing profile'),
                  ),
                  ElevatedButton(
                    onPressed: organizations.isEmpty
                        ? null
                        : () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            String? optional(String key) {
                              final value = controllers[key]!.text.trim();
                              return value.isEmpty ? null : value;
                            }

                            await widget.service.create(
                              BillingProfileInput(
                                organizationId: organizationId!,
                                label: controllers['label']!.text.trim(),
                                identityType: identityType,
                                legalName: controllers['legal']!.text.trim(),
                                billingEmail: controllers['email']!.text.trim(),
                                billingPhone: optional('phone'),
                                taxIdentifier: optional('tax'),
                                addressLineOne: controllers['address1']!.text
                                    .trim(),
                                addressLineTwo: optional('address2'),
                                city: controllers['city']!.text.trim(),
                                state: optional('state'),
                                postalCode: optional('postal'),
                                countryCode: controllers['country']!.text
                                    .trim()
                                    .toUpperCase(),
                                isDefault: isDefault,
                              ),
                            );
                            if (context.mounted) Navigator.pop(context);
                            refresh();
                          },
                    child: const Text('Save billing profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
