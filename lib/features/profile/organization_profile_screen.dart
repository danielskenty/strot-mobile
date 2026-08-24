import 'package:flutter/material.dart';
import '../../core/profile/organization_profile_service.dart';
import '../../design_system/strot_tokens.dart';

class OrganizationProfileScreen extends StatelessWidget {
  const OrganizationProfileScreen({super.key, required this.service});
  final OrganizationProfileService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Organization details')),
    body: FutureBuilder<List<OrganizationProfileRecord>>(
      future: service.list(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.requireData.isEmpty) {
          return const Center(
            child: Text('No organization membership is assigned.'),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: snapshot.requireData
              .map((item) => _OrganizationForm(item: item, service: service))
              .toList(),
        );
      },
    ),
  );
}

class _OrganizationForm extends StatefulWidget {
  const _OrganizationForm({required this.item, required this.service});
  final OrganizationProfileRecord item;
  final OrganizationProfileService service;
  @override
  State<_OrganizationForm> createState() => _OrganizationFormState();
}

class _OrganizationFormState extends State<_OrganizationForm> {
  late final controllers = <String, TextEditingController>{
    'name': TextEditingController(text: widget.item.name),
    'legal': TextEditingController(text: widget.item.legalName),
    'registration': TextEditingController(text: widget.item.registrationNumber),
    'email': TextEditingController(text: widget.item.email),
    'phone': TextEditingController(text: widget.item.phone),
    'website': TextEditingController(text: widget.item.website),
    'address': TextEditingController(text: widget.item.address),
    'city': TextEditingController(text: widget.item.city),
    'country': TextEditingController(text: widget.item.country),
  };
  bool saving = false;
  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? value(String key) {
    final text = controllers[key]!.text.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: StrotSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ORGANIZATION SETTINGS',
          style: TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: StrotSpacing.sm),
        Text(widget.item.name, style: Theme.of(context).textTheme.displaySmall),
        Text(
          '${widget.item.type.replaceAll('_', ' ')} · ${widget.item.status}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: StrotSpacing.lg),
        for (final entry in [
          ('name', 'Display name'),
          ('legal', 'Legal name'),
          ('registration', 'Registration number'),
          ('email', 'Organization email'),
          ('phone', 'Organization phone'),
          ('website', 'Website'),
          ('address', 'Address'),
          ('city', 'City'),
          ('country', 'Country code'),
        ]) ...[
          TextField(
            controller: controllers[entry.$1],
            keyboardType: entry.$1 == 'email'
                ? TextInputType.emailAddress
                : entry.$1 == 'phone'
                ? TextInputType.phone
                : TextInputType.text,
            decoration: InputDecoration(labelText: entry.$2),
          ),
          const SizedBox(height: StrotSpacing.md),
        ],
        Text(
          'Organization type and status are controlled by STROT governance.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: StrotSpacing.md),
        ElevatedButton(
          onPressed: saving
              ? null
              : () async {
                  setState(() => saving = true);
                  await widget.service.update(
                    OrganizationProfileRecord(
                      id: widget.item.id,
                      name: value('name')!,
                      legalName: value('legal'),
                      registrationNumber: value('registration'),
                      email: value('email'),
                      phone: value('phone'),
                      website: value('website'),
                      address: value('address'),
                      city: value('city'),
                      country: value('country')!,
                      type: widget.item.type,
                      status: widget.item.status,
                    ),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
          child: Text(saving ? 'Saving…' : 'Save organization'),
        ),
      ],
    ),
  );
}
