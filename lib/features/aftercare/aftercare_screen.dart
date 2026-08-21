import 'package:flutter/material.dart';
import '../../core/aftercare/aftercare_service.dart';
import '../../design_system/strot_tokens.dart';

class AftercareScreen extends StatelessWidget {
  const AftercareScreen({super.key, required this.service});
  final AftercareService service;
  @override
  Widget build(BuildContext context) => FutureBuilder<AftercareRecord>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = snapshot.data!;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'PROPERTY HANDOVER & CONTINUITY',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Handover and aftercare',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: StrotSpacing.xl),
          Text(
            'Handover packs',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ...data.packs.map(
            (item) => Card(
              child: ListTile(
                title: Text(item['reference'] as String),
                subtitle: Text((item['status'] as String).replaceAll('_', ' ')),
                leading: const Icon(Icons.inventory_2_outlined),
              ),
            ),
          ),
          const SizedBox(height: StrotSpacing.lg),
          Text('Warranties', style: Theme.of(context).textTheme.headlineMedium),
          ...data.warranties.map(
            (item) => Card(
              child: ListTile(
                title: Text(item['title'] as String),
                subtitle: Text(
                  '${item['provider']} · expires ${item['expires_on']}',
                ),
                trailing: Text(
                  item['status'] as String,
                  style: const TextStyle(color: StrotColors.gold),
                ),
              ),
            ),
          ),
          const SizedBox(height: StrotSpacing.lg),
          Text(
            'Defects and support',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ...data.defects.map(
            (item) => Card(
              child: ListTile(
                title: Text(item['title'] as String),
                subtitle: Text(item['reference'] as String),
                trailing: Text(
                  (item['status'] as String).replaceAll('_', ' '),
                  style: const TextStyle(color: StrotColors.gold),
                ),
              ),
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          const Text(
            'New defect reports can be submitted from the secure STROT web portal.',
          ),
        ],
      );
    },
  );
}
