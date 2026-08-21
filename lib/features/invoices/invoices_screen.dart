import 'package:flutter/material.dart';
import '../../core/invoices/invoice_models.dart';
import '../../core/invoices/invoice_service.dart';
import '../../core/payments/payment_collection_service.dart';
import '../payments/invoice_payment_screen.dart';
import '../../design_system/strot_tokens.dart';

String _money(int value) => '₦${(value / 100).toStringAsFixed(0)}';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key, required this.service, this.paymentService});
  final InvoiceService service;
  final PaymentCollectionService? paymentService;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<StrotInvoice>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'INVOICE REGISTER',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text('Invoices', style: Theme.of(context).textTheme.displayMedium),
          const Text('Issued obligations, reconciliation and receipt history.'),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.data!.map(
            (item) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(item.title),
                subtitle: Text(
                  '${item.reference} · ${_money(item.outstandingMinor)} outstanding\n${item.status}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => InvoiceDetailScreen(
                      item: item,
                      paymentService: paymentService,
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

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({
    super.key,
    required this.item,
    this.paymentService,
  });
  final StrotInvoice item;
  final PaymentCollectionService? paymentService;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Invoice record')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          item.reference,
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        Text(item.title, style: Theme.of(context).textTheme.displayMedium),
        Text(
          '${item.projectReference} · Due ${item.dueAt?.day}/${item.dueAt?.month}/${item.dueAt?.year}',
        ),
        const SizedBox(height: StrotSpacing.xl),
        Wrap(
          spacing: StrotSpacing.md,
          runSpacing: StrotSpacing.md,
          children: [
            _Metric('Invoice total', _money(item.totalMinor)),
            _Metric('Paid', _money(item.paidMinor)),
            _Metric('Outstanding', _money(item.outstandingMinor), accent: true),
          ],
        ),
        const SizedBox(height: StrotSpacing.lg),
        LinearProgressIndicator(
          value: item.totalMinor == 0 ? 0 : item.paidMinor / item.totalMinor,
        ),
        if (item.outstandingMinor > 0 && paymentService != null) ...[
          const SizedBox(height: StrotSpacing.lg),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InvoicePaymentScreen(
                  invoice: item,
                  service: paymentService!,
                ),
              ),
            ),
            child: const Text('Choose payment method'),
          ),
        ],
        const SizedBox(height: StrotSpacing.xl),
        Text(
          'Reconciliation history',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...item.transactions.map(
          (transaction) => Card(
            child: ListTile(
              title: Text(
                '${transaction.provider} · ${transaction.reference ?? 'Pending reference'}',
              ),
              subtitle: Text(transaction.status),
              trailing: Text(_money(transaction.amountMinor)),
            ),
          ),
        ),
      ],
    ),
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
      child: Padding(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: accent ? StrotColors.gold : StrotColors.forest,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
