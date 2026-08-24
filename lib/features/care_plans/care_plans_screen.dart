import 'package:flutter/material.dart';
import '../../core/care_plans/care_plan_service.dart';
import '../../design_system/strot_tokens.dart';

class CarePlansScreen extends StatelessWidget {
  const CarePlansScreen({super.key, required this.service});
  final CarePlanService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Care plans')),
    body: FutureBuilder<List<CarePlan>>(
      future: service.list(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'PLANNED CONTINUITY',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Service schedule',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const Text(
              'Upcoming property-care commitments and service coverage.',
            ),
            const SizedBox(height: StrotSpacing.xl),
            ...snapshot.data!.map(
              (plan) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(StrotSpacing.md),
                  title: Text(plan.name),
                  subtitle: Text(
                    '${plan.property} · ${plan.frequency}\nNext service ${plan.nextServiceOn}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CarePlanDetailScreen(plan: plan),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class CarePlanDetailScreen extends StatelessWidget {
  const CarePlanDetailScreen({super.key, required this.plan});
  final CarePlan plan;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Care plan')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          plan.frequency.toUpperCase(),
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: StrotSpacing.sm),
        Text(plan.name, style: Theme.of(context).textTheme.displayMedium),
        Text('${plan.property} · ${plan.status}'),
        const SizedBox(height: StrotSpacing.xl),
        Card(
          child: ListTile(
            title: const Text('Next scheduled service'),
            subtitle: Text(plan.nextServiceOn),
            trailing: Text(plan.scheduleState.replaceAll('_', ' ')),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Included service scope',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                ...plan.scope.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(item),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
