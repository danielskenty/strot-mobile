import 'package:flutter/material.dart';
import '../../core/admin/admin_service.dart';
import '../../design_system/strot_tokens.dart';
import 'global_search_screen.dart';
import 'audit_explorer_screen.dart';
import 'system_health_screen.dart';
import 'reports_screen.dart';

class OperationsQueueScreen extends StatelessWidget {
  const OperationsQueueScreen({super.key, required this.service});
  final AdminService service;
  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<OperationsQueueItem>>(
    future: service.operationsQueue(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final items = snapshot.data!;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'UNIFIED OPERATIONS QUEUE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Work requiring attention',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: StrotSpacing.md),
          OutlinedButton.icon(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => GlobalSearchScreen(service: service),
              ),
            ),
            icon: const Icon(Icons.search),
            label: const Text('Global record search'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => AuditExplorerScreen(service: service),
              ),
            ),
            icon: const Icon(Icons.history),
            label: const Text('Immutable audit explorer'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => SystemHealthScreen(service: service),
              ),
            ),
            icon: const Icon(Icons.monitor_heart_outlined),
            label: const Text('System health & recovery'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => ReportsScreen(service: service),
              ),
            ),
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Reports & analytics'),
          ),
          const SizedBox(height: StrotSpacing.sm),
          const Text(
            'Prioritized unresolved records across operational modules.',
          ),
          const SizedBox(height: StrotSpacing.xl),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(StrotSpacing.lg),
                child: Text('No unresolved operational records.'),
              ),
            ),
          ...items.map(
            (item) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(item.title),
                subtitle: Text(
                  '${item.category.replaceAll('_', ' ')} · ${item.context}\n${item.priority.replaceAll('_', ' ')}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(StrotSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: StrotSpacing.md),
                        Text(item.context),
                        const SizedBox(height: StrotSpacing.md),
                        Text(
                          'Exact destination: ${item.deepLink}',
                          style: const TextStyle(
                            color: StrotColors.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
