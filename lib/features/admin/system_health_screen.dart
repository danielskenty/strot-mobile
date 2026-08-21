import 'package:flutter/material.dart';
import '../../core/admin/admin_service.dart';
import '../../design_system/strot_tokens.dart';

class SystemHealthScreen extends StatelessWidget {
  const SystemHealthScreen({super.key, required this.service});
  final AdminService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('System health')),
    body: FutureBuilder<SystemHealthData>(
      future: service.systemHealth(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'JOBS, INCIDENTS & RECOVERY',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Operational health centre',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(data.status.replaceAll('_', ' ')),
            const SizedBox(height: StrotSpacing.xl),
            ...data.components.map(
              (item) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(StrotSpacing.md),
                  title: Text(item['name'] as String),
                  subtitle: Text(item['metric'] as String),
                  trailing: Text(
                    (item['status'] as String).replaceAll('_', ' '),
                  ),
                ),
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            const Text(
              'Credentials, queue payloads and exception traces are excluded from this view.',
              style: TextStyle(color: StrotColors.charcoalMuted),
            ),
          ],
        );
      },
    ),
  );
}
