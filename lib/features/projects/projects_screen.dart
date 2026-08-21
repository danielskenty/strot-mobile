import 'package:flutter/material.dart';
import '../../core/projects/project_models.dart';
import '../../core/projects/project_service.dart';
import '../../design_system/strot_tokens.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key, required this.service});
  final ProjectService service;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<StrotProject>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'CLIENT PORTFOLIO',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text('Projects', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: StrotSpacing.sm),
          const Text('Your active and completed property engagements.'),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.data!.map(
            (project) => Card(
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProjectOverviewScreen(project: project),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(StrotSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.reference,
                        style: const TextStyle(
                          color: StrotColors.gold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: StrotSpacing.sm),
                      Text(
                        project.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: StrotSpacing.sm),
                      Text('${project.type} · ${project.location}'),
                      const Divider(height: StrotSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Datum(
                            'Evidence',
                            '${project.summary.evidenceProgress}%',
                          ),
                          _Datum(
                            'Decisions',
                            '${project.summary.pendingApprovals} pending',
                          ),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ],
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

class ProjectOverviewScreen extends StatelessWidget {
  const ProjectOverviewScreen({super.key, required this.project});
  final StrotProject project;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(project.name)),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          project.reference,
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: StrotSpacing.sm),
        Text(project.name, style: Theme.of(context).textTheme.displayMedium),
        Text('${project.type} · ${project.location}'),
        const SizedBox(height: StrotSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery stages',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: StrotSpacing.xl),
                ...project.milestones.map(
                  (item) => ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    leading: Icon(
                      item.status == 'complete'
                          ? Icons.check_circle
                          : item.status == 'active'
                          ? Icons.adjust
                          : Icons.circle_outlined,
                      color: item.status == 'active'
                          ? StrotColors.gold
                          : StrotColors.forest,
                    ),
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.status} · ${item.completedRequirements}/${item.requirements.length} ready · ${item.ownerLabel ?? 'STROT team'}',
                    ),
                    children: [
                      if (item.description != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: StrotSpacing.sm,
                          ),
                          child: Text(item.description!),
                        ),
                      ...item.requirements.map(
                        (requirement) => ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(
                            left: StrotSpacing.md,
                          ),
                          leading: Icon(
                            requirement.complete
                                ? Icons.check
                                : Icons.circle_outlined,
                            color: requirement.complete
                                ? StrotColors.forest
                                : StrotColors.gold,
                          ),
                          title: Text(requirement.label),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: StrotSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Verified evidence'),
                const SizedBox(height: StrotSpacing.sm),
                LinearProgressIndicator(
                  value: project.summary.evidenceProgress / 100,
                ),
                const SizedBox(height: StrotSpacing.sm),
                Text(
                  '${project.summary.evidenceProgress}% reviewed',
                  style: const TextStyle(color: StrotColors.gold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: StrotSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Stage readiness'),
                    Text(
                      '${project.summary.milestoneProgress}%',
                      style: const TextStyle(
                        color: StrotColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StrotSpacing.sm),
                LinearProgressIndicator(
                  value: project.summary.milestoneProgress / 100,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: StrotSpacing.md),
        Container(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: StrotColors.gold),
          ),
          child: Text(
            '${project.summary.pendingApprovals} decisions await your review',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    ),
  );
}

class _Datum extends StatelessWidget {
  const _Datum(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: StrotColors.charcoalMuted)),
      const SizedBox(height: StrotSpacing.xs),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: StrotColors.forest,
        ),
      ),
    ],
  );
}
