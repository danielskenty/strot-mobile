import 'package:flutter/material.dart';
import '../../design_system/strot_tokens.dart';

class DesignSystemShowcase extends StatelessWidget {
  const DesignSystemShowcase({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('STROT  ·  Design System')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          'Architectural Editorial',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: StrotSpacing.sm),
        const Text(
          'A refined operational system for projects, property and trusted delivery.',
        ),
        const SizedBox(height: StrotSpacing.xl),
        Wrap(
          spacing: StrotSpacing.sm,
          runSpacing: StrotSpacing.sm,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Primary action'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Secondary action'),
            ),
            const Chip(
              avatar: Icon(Icons.verified_outlined),
              label: Text('Verified'),
            ),
          ],
        ),
        const SizedBox(height: StrotSpacing.xl),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Project name',
            hintText: 'Oak Residence',
          ),
        ),
        const SizedBox(height: StrotSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project readiness',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: StrotSpacing.md),
                const LinearProgressIndicator(value: .68),
                const SizedBox(height: StrotSpacing.md),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Documentation reviewed'), Text('68%')],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: StrotSpacing.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Milestone')),
              DataColumn(label: Text('Status')),
            ],
            rows: const [
              DataRow(
                cells: [
                  DataCell(Text('Site verification')),
                  DataCell(Text('Complete')),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text('Scope approval')),
                  DataCell(Text('Action required')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: StrotSpacing.lg),
        OutlinedButton.icon(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Confirm approval'),
              content: const Text(
                'This decision will be recorded in the project audit history.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Preview modal'),
        ),
      ],
    ),
  );
}
