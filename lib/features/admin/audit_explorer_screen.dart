import 'package:flutter/material.dart';
import '../../core/admin/admin_service.dart';
import '../../design_system/strot_tokens.dart';

class AuditExplorerScreen extends StatelessWidget {
  const AuditExplorerScreen({super.key, required this.service});
  final AdminService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Audit explorer')),
    body: FutureBuilder<List<AuditRecordItem>>(
      future: service.auditEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'IMMUTABLE AUDIT EXPLORER',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Who changed what, and when',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: StrotSpacing.xl),
            ...snapshot.data!.map(
              (item) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(StrotSpacing.md),
                  title: Text(item.event),
                  subtitle: Text(
                    '${item.record} · ${item.actor}\n${item.occurredAt}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
