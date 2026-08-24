import 'package:flutter/material.dart';
import '../../core/project_journal/project_journal_models.dart';
import '../../core/project_journal/project_journal_service.dart';
import '../../design_system/strot_tokens.dart';

class ProjectJournalScreen extends StatefulWidget {
  const ProjectJournalScreen({
    super.key,
    required this.service,
    required this.onOpen,
  });
  final ProjectJournalService service;
  final Future<void> Function(String deepLink) onOpen;
  @override
  State<ProjectJournalScreen> createState() => _ProjectJournalScreenState();
}

class _ProjectJournalScreenState extends State<ProjectJournalScreen> {
  late Future<ProjectJournal> future;
  int? projectId;

  @override
  void initState() {
    super.initState();
    future = widget.service.get();
  }

  void selectProject(int? value) {
    setState(() {
      projectId = value;
      future = widget.service.get(projectId: value);
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<ProjectJournal>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('◇ ${snapshot.error}'));
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = snapshot.data!;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'CERTIFIED CLIENT RECORD',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Project journal',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Text(
            'Verified progress, field updates, inspections and approved evidence in chronological order.',
          ),
          const SizedBox(height: StrotSpacing.xl),
          Wrap(
            spacing: StrotSpacing.md,
            runSpacing: StrotSpacing.md,
            children: [
              _Measure(label: 'Journal records', value: data.summary.total),
              _Measure(label: 'Certified', value: data.summary.certified),
              _Measure(label: 'Site updates', value: data.summary.siteUpdates),
              _Measure(label: 'Inspections', value: data.summary.inspections),
            ],
          ),
          const SizedBox(height: StrotSpacing.xl),
          DropdownButtonFormField<int?>(
            key: const Key('journal-project-filter'),
            initialValue: projectId,
            decoration: const InputDecoration(labelText: 'Project'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All authorized projects'),
              ),
              ...data.projects.map(
                (project) => DropdownMenuItem<int?>(
                  value: project.id,
                  child: Text('${project.reference} · ${project.name}'),
                ),
              ),
            ],
            onChanged: selectProject,
          ),
          const SizedBox(height: StrotSpacing.xl),
          if (data.entries.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(StrotSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No journal records yet'),
                    SizedBox(height: StrotSpacing.sm),
                    Text(
                      'Verified progress and field records will appear here as delivery activity is recorded.',
                    ),
                  ],
                ),
              ),
            ),
          ...data.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: StrotSpacing.md),
              child: _JournalEntryCard(entry: entry, onOpen: widget.onOpen),
            ),
          ),
        ],
      );
    },
  );
}

class _Measure extends StatelessWidget {
  const _Measure({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    padding: const EdgeInsets.all(StrotSpacing.md),
    decoration: BoxDecoration(
      border: Border.all(color: StrotColors.forestMuted),
      borderRadius: BorderRadius.circular(StrotRadius.md),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: StrotSpacing.sm),
        Text('$value', style: Theme.of(context).textTheme.headlineMedium),
      ],
    ),
  );
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry, required this.onOpen});
  final ProjectJournalEntry entry;
  final Future<void> Function(String deepLink) onOpen;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      key: Key('journal-entry-${entry.id}'),
      onTap: () => onOpen(entry.deepLink),
      child: Padding(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.type.replaceAll('_', ' ').toUpperCase()} · ${entry.project.reference}',
                        style: const TextStyle(
                          color: StrotColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: StrotSpacing.sm),
                      Text(
                        entry.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StrotSpacing.sm,
                    vertical: StrotSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: StrotColors.gold),
                    color: entry.certified
                        ? StrotColors.goldMuted
                        : StrotColors.cream,
                  ),
                  child: Text(
                    entry.certified
                        ? 'Certified'
                        : entry.status.replaceAll('_', ' '),
                  ),
                ),
              ],
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(entry.summary),
            if (entry.secondary != null) ...[
              const SizedBox(height: StrotSpacing.sm),
              Text(
                entry.secondary!,
                style: const TextStyle(color: StrotColors.charcoalMuted),
              ),
            ],
            const Divider(height: StrotSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${entry.occurredAt.toIso8601String().split('T').first}${entry.actor == null ? '' : ' · ${entry.actor}'}',
                  ),
                ),
                const Text(
                  'Open exact record →',
                  style: TextStyle(
                    color: StrotColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
