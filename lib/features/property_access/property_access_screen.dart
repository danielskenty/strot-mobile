import 'package:flutter/material.dart';
import '../../core/properties/property_service.dart';
import '../../core/property_access/property_access_models.dart';
import '../../core/property_access/property_access_service.dart';
import '../../design_system/strot_tokens.dart';

class PropertyAccessScreen extends StatefulWidget {
  const PropertyAccessScreen({
    super.key,
    required this.service,
    required this.propertyService,
  });
  final PropertyAccessService service;
  final PropertyService propertyService;
  @override
  State<PropertyAccessScreen> createState() => _PropertyAccessScreenState();
}

class _PropertyAccessScreenState extends State<PropertyAccessScreen> {
  late Future<List<PropertyAccessRecord>> future;
  @override
  void initState() {
    super.initState();
    future = widget.service.list();
  }

  void refresh() {
    future = widget.service.list();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _add,
      icon: const Icon(Icons.person_add_alt_1_outlined),
      label: const Text('Add record'),
    ),
    body: FutureBuilder<List<PropertyAccessRecord>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('◇ ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'PROPERTY ACCESS & CONTACTS',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Household and guest register',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const Text(
              'Manage contacts and time-bounded authorizations. Physical lock credentials are never displayed.',
            ),
            const SizedBox(height: StrotSpacing.xl),
            if (snapshot.data!.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(StrotSpacing.xl),
                  child: Text(
                    'No household members, guests or property contacts recorded.',
                  ),
                ),
              )
            else
              ...snapshot.data!.map(
                (record) => _RecordCard(
                  record: record,
                  onRevoke: () async {
                    await widget.service.revoke(record.id);
                    if (mounted) setState(refresh);
                  },
                ),
              ),
          ],
        );
      },
    ),
  );
  Future<void> _add() async {
    final properties = await widget.propertyService.list();
    if (!mounted) return;
    if (properties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authorized property is available.')),
      );
      return;
    }
    final result = await showDialog<_AccessInput>(
      context: context,
      builder: (_) => _AccessDialog(properties: properties),
    );
    if (result == null) return;
    await widget.service.create(
      propertyId: result.propertyId,
      type: result.type,
      name: result.name,
      relationship: result.relationship,
      phone: result.phone,
      emergencyContact: result.emergency,
      authorizedAreas: result.areas,
    );
    if (mounted) setState(refresh);
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onRevoke});
  final PropertyAccessRecord record;
  final Future<void> Function() onRevoke;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${record.type.replaceAll('_', ' ').toUpperCase()} · ${record.propertyReference}',
            style: const TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: StrotSpacing.sm),
          Text(record.name, style: Theme.of(context).textTheme.titleLarge),
          Text(record.relationship ?? record.propertyName),
          const Divider(height: StrotSpacing.xl),
          Text('Contact: ${record.phone ?? record.email ?? 'Not recorded'}'),
          Text(
            'Authorized areas: ${record.authorizedAreas.isEmpty ? 'Contact only' : record.authorizedAreas.join(', ')}',
          ),
          Text('Emergency contact: ${record.emergencyContact ? 'Yes' : 'No'}'),
          Text('Status: ${record.status}'),
          if (record.status == 'active') ...[
            const SizedBox(height: StrotSpacing.md),
            OutlinedButton(
              key: Key('revoke-access-${record.id}'),
              onPressed: onRevoke,
              child: const Text('Revoke authorization'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _AccessInput {
  const _AccessInput(
    this.propertyId,
    this.type,
    this.name,
    this.relationship,
    this.phone,
    this.emergency,
    this.areas,
  );
  final int propertyId;
  final String type, name;
  final String? relationship, phone;
  final bool emergency;
  final List<String> areas;
}

class _AccessDialog extends StatefulWidget {
  const _AccessDialog({required this.properties});
  final List<PropertyRecord> properties;
  @override
  State<_AccessDialog> createState() => _AccessDialogState();
}

class _AccessDialogState extends State<_AccessDialog> {
  int? propertyId;
  String type = 'household';
  bool emergency = false;
  final name = TextEditingController(),
      relationship = TextEditingController(),
      phone = TextEditingController(),
      areas = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    relationship.dispose();
    phone.dispose();
    areas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add access record'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            key: const Key('access-property-select'),
            initialValue: propertyId,
            decoration: const InputDecoration(labelText: 'Property'),
            items: widget.properties
                .map(
                  (p) => DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.reference} · ${p.name}'),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => propertyId = value),
          ),
          const SizedBox(height: StrotSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Record type'),
            items: const [
              DropdownMenuItem(
                value: 'household',
                child: Text('Household member'),
              ),
              DropdownMenuItem(
                value: 'guest',
                child: Text('Guest authorization'),
              ),
              DropdownMenuItem(
                value: 'property_contact',
                child: Text('Property contact'),
              ),
            ],
            onChanged: (value) => setState(() => type = value!),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            key: const Key('access-name'),
            controller: name,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            controller: relationship,
            decoration: const InputDecoration(
              labelText: 'Relationship or role',
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            controller: phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            controller: areas,
            decoration: const InputDecoration(
              labelText: 'Authorized areas, comma separated',
            ),
          ),
          SwitchListTile(
            value: emergency,
            onChanged: (value) => setState(() => emergency = value),
            title: const Text('Emergency contact'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (propertyId == null || name.text.trim().isEmpty) return;
          Navigator.pop(
            context,
            _AccessInput(
              propertyId!,
              type,
              name.text.trim(),
              relationship.text.trim().isEmpty
                  ? null
                  : relationship.text.trim(),
              phone.text.trim().isEmpty ? null : phone.text.trim(),
              emergency,
              areas.text
                  .split(',')
                  .map((v) => v.trim())
                  .where((v) => v.isNotEmpty)
                  .toList(),
            ),
          );
        },
        child: const Text('Add to register'),
      ),
    ],
  );
}
