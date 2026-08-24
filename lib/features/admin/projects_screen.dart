import 'package:flutter/material.dart';
import '../../core/admin/project_directory_service.dart';
import '../../design_system/strot_tokens.dart';

class AdminProjectsScreen extends StatelessWidget {
  const AdminProjectsScreen({super.key, required this.service});
  final AdminProjectDirectoryService service;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<AdminProjectRecord>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'DELIVERY GOVERNANCE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Platform projects',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Text('Client ownership and operational workload across STROT.'),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.data!.map(
            (project) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(project.name),
                subtitle: Text(
                  '${project.reference}\n${project.client} · ${project.status}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => AdminProjectDetailScreen(
                      service: service,
                      id: project.id,
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

class AdminProjectDetailScreen extends StatelessWidget {
  const AdminProjectDetailScreen({
    super.key,
    required this.service,
    required this.id,
  });
  final AdminProjectDirectoryService service;
  final int id;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Project governance')),
    body: FutureBuilder<AdminProjectRecord>(
      future: service.get(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final project = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              project.reference,
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              project.name,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text('${project.client} · ${project.status}'),
            const SizedBox(height: StrotSpacing.xl),
            _section(context, 'Milestones', project.milestones, 'title'),
            _section(context, 'Tasks', project.tasks, 'title'),
            _section(context, 'Approvals', project.approvals, 'title'),
            _section(context, 'Documents', project.documents, 'name'),
          ],
        );
      },
    ),
  );

  Widget _section(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> rows,
    String primary,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          if (rows.isEmpty)
            const Text('No records.')
          else
            ...rows.map(
              (row) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(row[primary]?.toString() ?? ''),
                trailing: Text(
                  (row['status']?.toString() ?? '').replaceAll('_', ' '),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
