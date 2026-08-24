import 'package:flutter/material.dart';
import '../../core/admin/provider_dispatch_service.dart';
import '../../design_system/strot_tokens.dart';

class ProviderDispatchScreen extends StatefulWidget {
  const ProviderDispatchScreen({super.key, required this.service});
  final ProviderDispatchService service;
  @override
  State<ProviderDispatchScreen> createState() => _ProviderDispatchScreenState();
}

class _ProviderDispatchScreenState extends State<ProviderDispatchScreen> {
  late Future<ProviderDispatchRecord> record = widget.service.load();
  void reload() => setState(() => record = widget.service.load());
  @override
  Widget build(BuildContext context) => FutureBuilder<ProviderDispatchRecord>(
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
            'SERVICE-PROVIDER ORCHESTRATION',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Provider request dispatch',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: StrotSpacing.sm),
          const Text(
            'Assign structured service requests and priorities to approved providers.',
          ),
          const SizedBox(height: StrotSpacing.lg),
          ElevatedButton.icon(
            onPressed: data.providers.isEmpty ? null : () => create(data),
            icon: const Icon(Icons.add),
            label: const Text('Dispatch request'),
          ),
          const SizedBox(height: StrotSpacing.xl),
          ...data.requests.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['service'] as String,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: StrotSpacing.xs),
                    Text(
                      '${item['reference']} · ${(item['provider_organization'] as Map<String, dynamic>)['name']}',
                      style: const TextStyle(color: StrotColors.charcoalMuted),
                    ),
                    const SizedBox(height: StrotSpacing.md),
                    Text(item['summary'] as String),
                    const Divider(height: StrotSpacing.xl),
                    Text(
                      '${item['priority']} · ${item['status']}'.replaceAll(
                        '_',
                        ' ',
                      ),
                      style: const TextStyle(
                        color: StrotColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item['status'] == 'fulfilled') ...[
                      const SizedBox(height: StrotSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => review(item),
                          child: const Text('Review provider result'),
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

  Future<void> create(ProviderDispatchRecord data) async {
    final service = TextEditingController();
    final summary = TextEditingController();
    var provider = data.providers.first['id'] as int;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Dispatch provider request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: provider,
                decoration: const InputDecoration(labelText: 'Provider'),
                items: data.providers
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['id'] as int,
                        child: Text(item['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setDialogState(() => provider = value!),
              ),
              const SizedBox(height: StrotSpacing.md),
              TextField(
                controller: service,
                decoration: const InputDecoration(labelText: 'Service'),
              ),
              const SizedBox(height: StrotSpacing.md),
              TextField(
                controller: summary,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Summary'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Dispatch'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) {
      await widget.service.create({
        'provider_organization_id': provider,
        'service': service.text.trim(),
        'summary': summary.text.trim(),
        'priority': 'action_required',
      });
      reload();
    }
    service.dispose();
    summary.dispose();
  }

  Future<void> review(Map<String, dynamic> item) async {
    var decision = 'verify';
    final note = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Provider result review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: decision,
                decoration: const InputDecoration(labelText: 'Decision'),
                items: const [
                  DropdownMenuItem(
                    value: 'verify',
                    child: Text('Verify result'),
                  ),
                  DropdownMenuItem(
                    value: 'request_correction',
                    child: Text('Request correction'),
                  ),
                ],
                onChanged: (value) => setDialogState(() => decision = value!),
              ),
              const SizedBox(height: StrotSpacing.md),
              TextField(
                controller: note,
                maxLines: 3,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(labelText: 'Review note'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  decision == 'request_correction' && note.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Record review'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) {
      await widget.service.review(
        item['id'] as int,
        decision,
        note.text.trim().isEmpty ? null : note.text.trim(),
      );
      reload();
    }
    note.dispose();
  }
}
