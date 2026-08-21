import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/payments/payment_admin_service.dart';
import '../../design_system/strot_tokens.dart';
import 'invoice_payment_screen.dart';

class PaymentAdminScreen extends StatefulWidget {
  const PaymentAdminScreen({
    super.key,
    required this.service,
    required this.api,
  });
  final PaymentAdminService service;
  final ApiClient api;
  @override
  State<PaymentAdminScreen> createState() => _PaymentAdminScreenState();
}

class _PaymentAdminScreenState extends State<PaymentAdminScreen> {
  String? filter;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<AdminPaymentReview>>(
    future: widget.service.reviews(status: filter),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'FINANCE CONTROL',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          Text(
            'Payment review',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Text('Verify receiving-bank credits before recognising funds.'),
          const SizedBox(height: StrotSpacing.lg),
          Wrap(
            spacing: StrotSpacing.sm,
            children: [
              for (final value in <String?>[
                null,
                'awaiting_confirmation',
                'under_review',
                'confirmed',
              ])
                ChoiceChip(
                  label: Text(value?.replaceAll('_', ' ') ?? 'all'),
                  selected: filter == value,
                  onSelected: (_) => setState(() => filter = value),
                ),
            ],
          ),
          const SizedBox(height: StrotSpacing.lg),
          ...snapshot.data!.map(
            (item) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(item.reference),
                subtitle: Text(
                  '${item.projectReference} · ${item.invoiceReference}\n${item.senderName} · ${paymentMoney(item.amountMinor)}',
                ),
                isThreeLine: true,
                trailing: Text(
                  item.status.replaceAll('_', ' '),
                  style: const TextStyle(
                    color: StrotColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () => Navigator.of(context)
                    .push(
                      MaterialPageRoute<void>(
                        builder: (_) => PaymentReviewDetailScreen(
                          service: widget.service,
                          id: item.id,
                        ),
                      ),
                    )
                    .then((_) => setState(() {})),
              ),
            ),
          ),
          const SizedBox(height: StrotSpacing.lg),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PaymentRefundScreen(service: widget.service),
              ),
            ),
            child: const Text('Open refund register'),
          ),
        ],
      );
    },
  );
}

class PaymentReviewDetailScreen extends StatefulWidget {
  const PaymentReviewDetailScreen({
    super.key,
    required this.service,
    required this.id,
  });
  final PaymentAdminService service;
  final String id;
  @override
  State<PaymentReviewDetailScreen> createState() =>
      _PaymentReviewDetailScreenState();
}

class _PaymentReviewDetailScreenState extends State<PaymentReviewDetailScreen> {
  final note = TextEditingController(),
      amount = TextEditingController(),
      date = TextEditingController(),
      reference = TextEditingController();
  bool busy = false;
  String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Payment review')),
    body: FutureBuilder<AdminPaymentReview>(
      future: widget.service.review(widget.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = snapshot.data!;
        final canStart = item.status == 'awaiting_confirmation';
        final canDecide = item.status == 'under_review';
        if (amount.text.isEmpty) {
          amount.text = (item.amountMinor / 100).toStringAsFixed(2);
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              item.reference,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text('${item.projectReference} · ${item.invoiceReference}'),
            const SizedBox(height: StrotSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMoney(item.amountMinor),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: StrotColors.gold),
                    ),
                    Text('Expected ${paymentMoney(item.expectedMinor)}'),
                    Text(
                      '${item.senderName} · ${item.senderBank ?? 'Bank not supplied'}',
                    ),
                    Text(
                      'Claimed reference: ${item.bankReference ?? 'Not supplied'}',
                    ),
                    if (item.proofId != null)
                      Text(
                        'Evidence: ${item.proofName ?? item.proofId}',
                        style: const TextStyle(
                          color: StrotColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            TextField(
              controller: note,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Internal review note',
              ),
            ),
            if (canDecide) ...[
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Confirmed amount',
                ),
              ),
              TextField(
                controller: date,
                decoration: const InputDecoration(
                  labelText: 'Bank credit date (YYYY-MM-DD)',
                ),
              ),
              TextField(
                controller: reference,
                decoration: const InputDecoration(
                  labelText: 'Confirmed bank reference',
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: StrotSpacing.md),
                child: Text(
                  'High-value confirmation requires a recently verified two-factor session.',
                ),
              ),
            ],
            if (error != null)
              Text(error!, style: const TextStyle(color: StrotColors.forest)),
            if (canStart)
              ElevatedButton(
                onPressed: busy ? null : () => _decide('start_review'),
                child: const Text('Start review'),
              ),
            if (canDecide) ...[
              ElevatedButton(
                onPressed: busy ? null : () => _decide('confirm'),
                child: const Text('Confirm received funds'),
              ),
              OutlinedButton(
                onPressed: busy ? null : () => _decide('request_correction'),
                child: const Text('Request correction'),
              ),
              OutlinedButton(
                onPressed: busy ? null : () => _decide('reject'),
                child: const Text('Reject submission'),
              ),
            ],
            if (canStart || canDecide)
              OutlinedButton(
                onPressed: busy ? null : () => _decide('duplicate'),
                child: const Text('Mark duplicate'),
              ),
          ],
        );
      },
    ),
  );
  Future<void> _decide(String action) async {
    if (note.text.trim().isEmpty) {
      setState(() => error = 'A review note is required.');
      return;
    }
    setState(() => busy = true);
    try {
      await widget.service.decide(
        widget.id,
        action,
        note: note.text.trim(),
        confirmedAmountMinor: action == 'confirm'
            ? (double.parse(amount.text) * 100).round()
            : null,
        bankCreditDate: action == 'confirm' ? date.text : null,
        confirmedReference: action == 'confirm' ? reference.text : null,
        declaration: action == 'confirm',
      );
      if (mounted) Navigator.pop(context);
    } catch (value) {
      if (mounted) setState(() => error = value.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class PaymentRefundScreen extends StatefulWidget {
  const PaymentRefundScreen({super.key, required this.service});
  final PaymentAdminService service;
  @override
  State<PaymentRefundScreen> createState() => _PaymentRefundScreenState();
}

class _PaymentRefundScreenState extends State<PaymentRefundScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Refund register')),
    body: FutureBuilder<List<AdminPaymentRefund>>(
      future: widget.service.refunds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: snapshot.data!
              .map(
                (item) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(StrotSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.reference,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${item.projectReference} · ${item.invoiceReference}',
                        ),
                        Text(
                          paymentMoney(item.amountMinor),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: StrotColors.gold),
                        ),
                        Text(item.reason),
                        Text(item.status),
                        if (item.status == 'requested')
                          Wrap(
                            spacing: StrotSpacing.sm,
                            children: [
                              ElevatedButton(
                                onPressed: () => _change(item, 'approved'),
                                child: const Text('Approve'),
                              ),
                              OutlinedButton(
                                onPressed: () => _change(item, 'rejected'),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        if (item.status == 'approved')
                          ElevatedButton(
                            onPressed: () => _processed(item),
                            child: const Text('Record external processing'),
                          ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    ),
  );
  Future<void> _change(AdminPaymentRefund item, String status) async {
    await widget.service.transitionRefund(item.id, status);
    if (mounted) setState(() {});
  }

  Future<void> _processed(AdminPaymentRefund item) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('External processing reference'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Record'),
          ),
        ],
      ),
    );
    if (value?.isNotEmpty == true) {
      await widget.service.transitionRefund(
        item.id,
        'processed',
        providerReference: value,
      );
      if (mounted) setState(() {});
    }
  }
}
