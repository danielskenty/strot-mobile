import 'package:flutter/material.dart';
import '../../core/payments/payment_service.dart';
import '../../design_system/strot_tokens.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key, required this.service});
  final PaymentService service;

  String money(int minor) {
    final value = (minor / 100).toStringAsFixed(0);
    return '₦${value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: service.getFinance(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final (summary, payments) = snapshot.data!;
      final progress = summary.approvedMinor == 0
          ? 0.0
          : summary.paidMinor / summary.approvedMinor;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'CLIENT FINANCE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Payments & receipts',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: StrotSpacing.xl),
          Wrap(
            spacing: StrotSpacing.md,
            runSpacing: StrotSpacing.md,
            children: [
              _Metric('Approved value', money(summary.approvedMinor)),
              _Metric('Paid to date', money(summary.paidMinor)),
              _Metric(
                'Outstanding',
                money(summary.outstandingMinor),
                accent: true,
              ),
            ],
          ),
          const SizedBox(height: StrotSpacing.lg),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: StrotSpacing.xl),
          Text(
            'Payment schedule',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: StrotSpacing.md),
          ...payments.map(
            (item) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(item.label),
                subtitle: Text(
                  '${money(item.amountMinor)} · ${item.date?.day}/${item.date?.month}/${item.date?.year}\n${item.reference ?? 'Payment request'}',
                ),
                isThreeLine: true,
                trailing: Text(
                  item.status,
                  style: const TextStyle(
                    color: StrotColors.gold,
                    fontWeight: FontWeight.w700,
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

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, {this.accent = false});
  final String label, value;
  final bool accent;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 210,
    child: Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: accent ? StrotColors.gold : StrotColors.forestMuted,
        ),
        borderRadius: BorderRadius.circular(StrotRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: StrotSpacing.md),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: accent ? StrotColors.gold : StrotColors.forest,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
