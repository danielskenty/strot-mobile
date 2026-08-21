import 'package:flutter/material.dart';
import '../../core/provider/provider_service.dart';
import '../../design_system/strot_tokens.dart';

class ProviderOperationsScreen extends StatefulWidget {
  const ProviderOperationsScreen({super.key, required this.service});
  final ProviderService service;
  @override
  State<ProviderOperationsScreen> createState() =>
      _ProviderOperationsScreenState();
}

class _ProviderOperationsScreenState extends State<ProviderOperationsScreen> {
  late Future<ProviderOperations> operations = widget.service.list();
  void refresh() => setState(() => operations = widget.service.list());
  @override
  Widget build(BuildContext context) => FutureBuilder<ProviderOperations>(
    future: operations,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = snapshot.data!;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'PROVIDER OPERATIONS',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Fulfilment console',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: StrotSpacing.xl),
          Wrap(
            spacing: StrotSpacing.md,
            runSpacing: StrotSpacing.md,
            children: [
              _ProviderMetric(
                'Open requests',
                '${data.jobs.where((job) => !['fulfilled', 'unable_to_fulfil'].contains(job.status)).length}',
              ),
              _ProviderMetric(
                'Operational',
                '${data.integrations.where((item) => item.status == 'operational').length}',
              ),
            ],
          ),
          const SizedBox(height: StrotSpacing.xl),
          ...data.jobs.map(
            (job) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(job.service),
                subtitle: Text('${job.reference} · ${job.summary}'),
                trailing: Text(
                  job.status.replaceAll('_', ' '),
                  style: const TextStyle(
                    color: StrotColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProviderJobScreen(job: job, service: widget.service),
                    ),
                  );
                  refresh();
                },
              ),
            ),
          ),
          const SizedBox(height: StrotSpacing.lg),
          Text(
            'Integration health',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ...data.integrations.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(
                  '${item.environment} · ${item.status}\n${item.openIncidents} open incidents · ${item.consecutiveFailures} consecutive failures',
                ),
                isThreeLine: true,
                trailing: Text(
                  item.latencyMs == null ? '—' : '${item.latencyMs} ms',
                  style: const TextStyle(
                    color: StrotColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProviderIntegrationScreen(
                        item: item,
                        service: widget.service,
                      ),
                    ),
                  );
                  refresh();
                },
              ),
            ),
          ),
        ],
      );
    },
  );
}

class ProviderIntegrationScreen extends StatefulWidget {
  const ProviderIntegrationScreen({
    super.key,
    required this.item,
    required this.service,
  });
  final ProviderIntegrationHealth item;
  final ProviderService service;
  @override
  State<ProviderIntegrationScreen> createState() =>
      _ProviderIntegrationScreenState();
}

class _ProviderIntegrationScreenState extends State<ProviderIntegrationScreen> {
  final latency = TextEditingController(),
      code = TextEditingController(),
      message = TextEditingController();
  String status = 'operational';
  bool saving = false;
  String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Integration health')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          widget.item.name,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Text('${widget.item.environment} · ${widget.item.status}'),
        const SizedBox(height: StrotSpacing.lg),
        Wrap(
          spacing: StrotSpacing.sm,
          children: widget.item.capabilities
              .map((value) => Chip(label: Text(value.replaceAll('_', ' '))))
              .toList(),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record health check',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: const [
                    DropdownMenuItem(
                      value: 'operational',
                      child: Text('Operational'),
                    ),
                    DropdownMenuItem(
                      value: 'degraded',
                      child: Text('Degraded'),
                    ),
                    DropdownMenuItem(value: 'outage', child: Text('Outage')),
                  ],
                  onChanged: (value) =>
                      setState(() => status = value ?? status),
                ),
                TextField(
                  controller: latency,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Latency in milliseconds',
                  ),
                ),
                TextField(
                  controller: code,
                  decoration: const InputDecoration(
                    labelText: 'Safe error code',
                  ),
                ),
                TextField(
                  controller: message,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Credential-free operational message',
                  ),
                ),
                if (error != null)
                  Text(
                    error!,
                    style: const TextStyle(color: StrotColors.forest),
                  ),
                ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: Text(saving ? 'Saving…' : 'Record health event'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await widget.service.reportHealth(
        widget.item.id,
        status,
        latencyMs: int.tryParse(latency.text),
        errorCode: code.text.trim().isEmpty ? null : code.text.trim(),
        message: message.text.trim().isEmpty ? null : message.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (value) {
      if (mounted) setState(() => error = value.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}

class ProviderJobScreen extends StatefulWidget {
  const ProviderJobScreen({
    super.key,
    required this.job,
    required this.service,
  });
  final ProviderJob job;
  final ProviderService service;
  @override
  State<ProviderJobScreen> createState() => _ProviderJobScreenState();
}

class _ProviderJobScreenState extends State<ProviderJobScreen> {
  final summary = TextEditingController();
  final reference = TextEditingController();
  bool saving = false;
  Future<void> transition(String status, {Map<String, String>? result}) async {
    setState(() => saving = true);
    try {
      await widget.service.transition(widget.job.id, status, result: result);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    summary.dispose();
    reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Provider request')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          widget.job.reference,
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          widget.job.service,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: StrotSpacing.md),
        Text(widget.job.summary),
        const SizedBox(height: StrotSpacing.xl),
        Text('Request data', style: Theme.of(context).textTheme.headlineMedium),
        ...widget.job.payload.entries.map(
          (entry) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(entry.key.replaceAll('_', ' ')),
            subtitle: Text('${entry.value}'),
          ),
        ),
        if (widget.job.status == 'pending') ...[
          FilledButton(
            onPressed: saving ? null : () => transition('accepted'),
            child: const Text('Accept request'),
          ),
          OutlinedButton(
            onPressed: saving
                ? null
                : () => transition(
                    'unable_to_fulfil',
                    result: {'failure_reason': 'Capacity unavailable'},
                  ),
            child: const Text('Unable to fulfil'),
          ),
        ],
        if (widget.job.status == 'accepted')
          FilledButton(
            onPressed: saving ? null : () => transition('in_progress'),
            child: const Text('Start work'),
          ),
        if (widget.job.status == 'in_progress') ...[
          TextField(
            controller: summary,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Result summary'),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            controller: reference,
            decoration: const InputDecoration(labelText: 'Provider reference'),
          ),
          const SizedBox(height: StrotSpacing.md),
          FilledButton(
            onPressed: saving || summary.text.trim().isEmpty
                ? null
                : () => transition(
                    'fulfilled',
                    result: {
                      'summary': summary.text.trim(),
                      'reference': reference.text.trim(),
                    },
                  ),
            child: const Text('Submit fulfilment'),
          ),
        ],
      ],
    ),
  );
}

class _ProviderMetric extends StatelessWidget {
  const _ProviderMetric(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: StrotSpacing.md),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    ),
  );
}
