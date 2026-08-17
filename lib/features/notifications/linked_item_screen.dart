import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../design_system/strot_tokens.dart';

class LinkedNotificationItemScreen extends StatelessWidget {
  const LinkedNotificationItemScreen({
    super.key,
    required this.client,
    required this.kind,
    required this.id,
    required this.useMocks,
  });
  final ApiClient client;
  final String kind;
  final int id;
  final bool useMocks;
  Future<Map<String, dynamic>> load() async {
    if (useMocks) {
      return kind == 'payments'
          ? {
              'label': 'Initial project deposit',
              'status': 'paid',
              'amount_minor': 20000000,
              'currency': 'NGN',
              'reference': 'STROT-001',
              'project': {'reference': 'STR-24001', 'name': 'Oak Residence'},
            }
          : {
              'name': 'Scope-of-Work-v2.1.pdf',
              'kind': 'project_document',
              'status': 'verified',
              'caption': 'Current approved scope for review.',
              'project': {'reference': 'STR-24001', 'name': 'Oak Residence'},
              'uploaded_by': {'name': 'STROT Operations'},
            };
    }
    final response = await client.get('/$kind/$id');
    return response['data'] as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(kind == 'payments' ? 'Payment record' : 'Document record'),
    ),
    body: FutureBuilder(
      future: load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('◇ ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = snapshot.data!;
        final project = item['project'] as Map<String, dynamic>?;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              (project?['reference'] as String? ?? 'STROT RECORD')
                  .toUpperCase(),
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              (item['label'] ?? item['name'] ?? 'Linked record') as String,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              '${project?['name'] ?? 'STROT'} · ${(item['status'] ?? 'recorded').toString().replaceAll('_', ' ')}',
            ),
            const SizedBox(height: StrotSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verified record details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(height: StrotSpacing.xl),
                    ..._details(item).map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: StrotSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                entry.$1,
                                style: const TextStyle(
                                  color: StrotColors.charcoalMuted,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.$2,
                                style: const TextStyle(
                                  color: StrotColors.forest,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            const Text(
              'This destination was opened directly from its notification record.',
              style: TextStyle(color: StrotColors.charcoalMuted),
            ),
          ],
        );
      },
    ),
  );
  List<(String, String)> _details(Map<String, dynamic> item) {
    if (kind == 'payments') {
      return [
        ('Reference', item['reference']?.toString() ?? 'Pending'),
        (
          'Amount',
          _money(
            item['amount_minor'] as int? ?? 0,
            item['currency'] as String? ?? 'NGN',
          ),
        ),
        ('Status', item['status']?.toString() ?? 'Pending'),
      ];
    }
    return [
      ('Type', item['kind']?.toString().replaceAll('_', ' ') ?? 'Document'),
      ('Status', item['status']?.toString() ?? 'Submitted'),
      ('Caption', item['caption']?.toString() ?? 'No caption'),
      (
        'Uploaded by',
        ((item['uploaded_by'] as Map<String, dynamic>?)?['name'])?.toString() ??
            'STROT',
      ),
    ];
  }

  String _money(int minor, String currency) =>
      '$currency ${(minor / 100).toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
}
