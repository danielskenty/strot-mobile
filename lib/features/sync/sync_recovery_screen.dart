import 'package:flutter/material.dart';
import '../../core/sync/sync_outbox.dart';
import '../../design_system/strot_tokens.dart';

class SyncRecoveryScreen extends StatefulWidget {
  const SyncRecoveryScreen({super.key, required this.outbox});
  final SyncOutbox outbox;
  @override
  State<SyncRecoveryScreen> createState() => _SyncRecoveryScreenState();
}

class _SyncRecoveryScreenState extends State<SyncRecoveryScreen> {
  @override
  void initState() {
    super.initState();
    widget.outbox.addListener(refresh);
    widget.outbox.load();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.outbox.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Synchronisation')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          widget.outbox.online ? 'CONNECTION AVAILABLE' : 'WORKING OFFLINE',
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: StrotSpacing.sm),
        Text('Recovery queue', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: StrotSpacing.sm),
        Text(
          widget.outbox.items.isEmpty
              ? 'All operational changes are safely synchronised.'
              : '${widget.outbox.items.length} change(s) are stored securely on this device until delivery succeeds.',
        ),
        const SizedBox(height: StrotSpacing.xl),
        if (widget.outbox.items.isNotEmpty)
          FilledButton.icon(
            onPressed: widget.outbox.syncing ? null : widget.outbox.retryAll,
            icon: const Icon(Icons.sync),
            label: Text(
              widget.outbox.syncing ? 'Synchronising…' : 'Retry all changes',
            ),
          ),
        const SizedBox(height: StrotSpacing.lg),
        ...widget.outbox.items.map(_item),
      ],
    ),
  );

  Widget _item(SyncItem item) => Container(
    margin: const EdgeInsets.only(bottom: StrotSpacing.sm),
    padding: const EdgeInsets.all(StrotSpacing.md),
    decoration: BoxDecoration(
      border: Border.all(
        color: item.status == SyncItemStatus.needsAttention
            ? StrotColors.gold
            : StrotColors.forestMuted,
      ),
    ),
    child: Row(
      children: [
        Icon(
          item.status == SyncItemStatus.needsAttention
              ? Icons.flag_outlined
              : Icons.schedule_outlined,
          color: StrotColors.gold,
        ),
        const SizedBox(width: StrotSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _label(item),
                style: const TextStyle(
                  color: StrotColors.forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                item.status == SyncItemStatus.needsAttention
                    ? 'Needs review before it can be applied'
                    : 'Queued · ${item.attempts} retries',
              ),
              if (item.lastError != null)
                Text(
                  item.lastError!,
                  style: const TextStyle(color: StrotColors.gold),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => widget.outbox.discard(item.id),
          child: const Text('Discard'),
        ),
      ],
    ),
  );

  String _label(SyncItem item) => item.path.startsWith('/tasks/')
      ? 'Task status update'
      : item.path == '/site-reports'
      ? 'Daily site report'
      : 'Operational change';
}
