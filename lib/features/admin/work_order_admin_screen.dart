import 'package:flutter/material.dart';
import '../../core/admin/work_order_admin_service.dart';
import '../../design_system/strot_tokens.dart';

class WorkOrderAdminScreen extends StatefulWidget {
  const WorkOrderAdminScreen({super.key, required this.service});
  final WorkOrderAdminService service;
  @override
  State<WorkOrderAdminScreen> createState() => _WorkOrderAdminScreenState();
}

class _WorkOrderAdminScreenState extends State<WorkOrderAdminScreen> {
  late Future<WorkOrderAdminRecord> record = widget.service.load();
  void reload() => setState(() => record = widget.service.load());
  @override
  Widget build(BuildContext context) => FutureBuilder<WorkOrderAdminRecord>(
    future: record,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = snapshot.requireData;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'PARTNER DELIVERY COMMISSIONING',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Work orders and assignments',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: StrotSpacing.sm),
          const Text(
            'Issue project briefs to active partners and track assignment responses.',
          ),
          const SizedBox(height: StrotSpacing.lg),
          ElevatedButton.icon(
            onPressed: data.projects.isEmpty || data.partners.isEmpty
                ? null
                : () => create(data),
            icon: const Icon(Icons.add),
            label: const Text('Assign partner'),
          ),
          const SizedBox(height: StrotSpacing.xl),
          ...data.orders.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: StrotSpacing.xs),
                    Text(
                      '${(item['project'] as Map<String, dynamic>)['reference']} · ${(item['partner_organization'] as Map<String, dynamic>)['name']}',
                      style: const TextStyle(color: StrotColors.charcoalMuted),
                    ),
                    const SizedBox(height: StrotSpacing.md),
                    Text(item['description'] as String),
                    const Divider(height: StrotSpacing.xl),
                    Text(
                      (item['status'] as String).replaceAll('_', ' '),
                      style: const TextStyle(
                        color: StrotColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ([
                      'ready_to_start',
                      'active',
                    ].contains(item['status'])) ...[
                      const SizedBox(height: StrotSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => lifecycle(
                            item,
                            item['status'] == 'ready_to_start'
                                ? 'start'
                                : 'complete',
                          ),
                          child: Text(
                            item['status'] == 'ready_to_start'
                                ? 'Authorize commencement'
                                : 'Confirm completion',
                          ),
                        ),
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
  );

  Future<void> create(WorkOrderAdminRecord data) async {
    final title = TextEditingController();
    final description = TextEditingController();
    var project = data.projects.first['id'] as int;
    var partner = data.partners.first['id'] as int;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assign partner'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: project,
                  decoration: const InputDecoration(labelText: 'Project'),
                  items: data.projects
                      .map(
                        (item) => DropdownMenuItem(
                          value: item['id'] as int,
                          child: Text(item['name'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setDialogState(() => project = value!),
                ),
                const SizedBox(height: StrotSpacing.md),
                DropdownButtonFormField<int>(
                  initialValue: partner,
                  decoration: const InputDecoration(
                    labelText: 'Active partner',
                  ),
                  items: data.partners
                      .map(
                        (item) => DropdownMenuItem(
                          value: item['id'] as int,
                          child: Text(item['name'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setDialogState(() => partner = value!),
                ),
                const SizedBox(height: StrotSpacing.md),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Work-order title',
                  ),
                ),
                const SizedBox(height: StrotSpacing.md),
                TextField(
                  controller: description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Delivery brief',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Issue assignment'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) {
      await widget.service.create({
        'project_id': project,
        'partner_organization_id': partner,
        'title': title.text.trim(),
        'description': description.text.trim(),
        'currency': 'NGN',
      });
      reload();
    }
    title.dispose();
    description.dispose();
  }

  Future<void> lifecycle(Map<String, dynamic> item, String action) async {
    final note = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          action == 'start' ? 'Authorize commencement' : 'Confirm completion',
        ),
        content: action == 'start'
            ? const Text('The partner will be notified that work may commence.')
            : TextField(
                controller: note,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Completion verification note',
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (accepted == true) {
      await widget.service.update(
        item['id'] as int,
        action,
        note.text.trim().isEmpty ? null : note.text.trim(),
      );
      reload();
    }
    note.dispose();
  }
}
