import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/invoices/invoice_models.dart';
import '../../core/payments/payment_collection_models.dart';
import '../../core/payments/payment_collection_service.dart';
import '../../design_system/strot_tokens.dart';

String paymentMoney(int minor) => '₦${(minor / 100).toStringAsFixed(0)}';

class InvoicePaymentScreen extends StatelessWidget {
  const InvoicePaymentScreen({
    super.key,
    required this.invoice,
    required this.service,
  });
  final StrotInvoice invoice;
  final PaymentCollectionService service;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Secure payment')),
    body: FutureBuilder<PaymentOptions>(
      future: service.options(invoice.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final options = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              invoice.title,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(
              '${invoice.reference} · ${paymentMoney(invoice.outstandingMinor)} outstanding',
            ),
            const SizedBox(height: StrotSpacing.xl),
            ...options.schedule
                .where((item) => item.amountDueMinor > 0)
                .map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.label),
                      subtitle: Text(paymentMoney(item.amountDueMinor)),
                      trailing: PopupMenuButton<String>(
                        onSelected: (method) => _open(context, method, item.id),
                        itemBuilder: (_) => [
                          if (options.nombaEnabled)
                            const PopupMenuItem(
                              value: 'nomba',
                              child: Text('Pay online with Nomba'),
                            ),
                          if (options.bankEnabled)
                            const PopupMenuItem(
                              value: 'bank',
                              child: Text('Bank transfer'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full outstanding balance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(paymentMoney(invoice.outstandingMinor)),
                    const SizedBox(height: StrotSpacing.lg),
                    Wrap(
                      spacing: StrotSpacing.sm,
                      children: [
                        ElevatedButton(
                          onPressed: options.nombaEnabled
                              ? () => _open(context, 'nomba', null)
                              : null,
                          child: const Text('Pay with Nomba'),
                        ),
                        OutlinedButton(
                          onPressed: options.bankEnabled
                              ? () => _open(context, 'bank', null)
                              : null,
                          child: const Text('Bank transfer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  Future<void> _open(
    BuildContext context,
    String method,
    int? scheduleId,
  ) async {
    if (method == 'bank') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BankTransferScreen(
            invoice: invoice,
            service: service,
            scheduleId: scheduleId,
          ),
        ),
      );
      return;
    }
    final attempt = await service.createNomba(
      invoice.id,
      scheduleId: scheduleId,
    );
    final url = Uri.tryParse(attempt.checkoutUrl ?? '');
    if (url == null ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      return;
    }
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NombaVerificationScreen(
            service: service,
            reference: attempt.orderReference ?? attempt.id,
          ),
        ),
      );
    }
  }
}

class NombaVerificationScreen extends StatefulWidget {
  const NombaVerificationScreen({
    super.key,
    required this.service,
    required this.reference,
  });
  final PaymentCollectionService service;
  final String reference;
  @override
  State<NombaVerificationScreen> createState() =>
      _NombaVerificationScreenState();
}

class _NombaVerificationScreenState extends State<NombaVerificationScreen> {
  PaymentAttempt? attempt;
  Timer? timer;
  String? error;
  int checks = 0;
  @override
  void initState() {
    super.initState();
    _verify();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    try {
      final value = await widget.service.verify(widget.reference);
      if (!mounted) return;
      setState(() => attempt = value);
      if (![
            'succeeded',
            'paid',
            'verified',
            'failed',
            'cancelled',
            'expired',
            'reversed',
          ].contains(value.status) &&
          checks++ < 30) {
        timer = Timer(const Duration(seconds: 3), _verify);
      }
    } catch (value) {
      if (mounted) setState(() => error = value.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = attempt?.status ?? 'verifying';
    final success = ['succeeded', 'paid', 'verified'].contains(status);
    return Scaffold(
      appBar: AppBar(title: const Text('Payment verification')),
      body: Padding(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOMBA CHECKOUT',
                  style: TextStyle(
                    color: StrotColors.gold,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: StrotSpacing.md),
                Text(
                  success ? 'Payment confirmed' : status.replaceAll('_', ' '),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: StrotSpacing.md),
                Text(
                  error ??
                      (success
                          ? 'STROT has reconciled this payment against the invoice.'
                          : 'The server is confirming the transaction. Returning from checkout never marks it as paid.'),
                ),
                if (!success && error == null)
                  const Padding(
                    padding: EdgeInsets.only(top: StrotSpacing.lg),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BankTransferScreen extends StatefulWidget {
  const BankTransferScreen({
    super.key,
    required this.invoice,
    required this.service,
    this.scheduleId,
  });
  final StrotInvoice invoice;
  final PaymentCollectionService service;
  final int? scheduleId;
  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  final sender = TextEditingController(),
      bank = TextEditingController(),
      reference = TextEditingController(),
      date = TextEditingController();
  PlatformFile? proof;
  bool busy = false;
  String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bank transfer')),
    body: FutureBuilder<BankTransferInstructions>(
      future: widget.service.bankInstructions(
        widget.invoice.id,
        scheduleId: widget.scheduleId,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final info = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.accountName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(info.bankName),
                    Text(
                      info.accountNumber,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      paymentMoney(info.amountMinor),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: StrotColors.gold),
                    ),
                    Text('Reference: ${info.paymentReference}'),
                    const SizedBox(height: StrotSpacing.md),
                    Text(info.notice),
                  ],
                ),
              ),
            ),
            const SizedBox(height: StrotSpacing.lg),
            TextField(
              controller: sender,
              decoration: const InputDecoration(
                labelText: 'Sender/account name',
              ),
            ),
            TextField(
              controller: bank,
              decoration: const InputDecoration(labelText: 'Sender bank'),
            ),
            TextField(
              controller: reference,
              decoration: const InputDecoration(
                labelText: 'Bank transaction reference',
              ),
            ),
            TextField(
              controller: date,
              decoration: const InputDecoration(
                labelText: 'Transfer date (YYYY-MM-DD)',
              ),
            ),
            OutlinedButton(
              onPressed: _pick,
              child: Text(proof?.name ?? 'Select proof (JPG, PNG or PDF)'),
            ),
            if (error != null)
              Text(error!, style: const TextStyle(color: StrotColors.forest)),
            ElevatedButton(
              onPressed: busy ? null : () => _submit(info),
              child: Text(
                busy ? 'Processing securely…' : 'Submit proof for review',
              ),
            ),
          ],
        );
      },
    ),
  );
  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result != null) setState(() => proof = result.files.single);
  }

  Future<void> _submit(BankTransferInstructions info) async {
    if (proof?.bytes == null ||
        sender.text.trim().isEmpty ||
        date.text.trim().isEmpty) {
      setState(() => error = 'Sender, transfer date and proof are required.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final extension = proof!.extension?.toLowerCase();
      final record = await widget.service.submitBankProof(
        invoiceId: widget.invoice.id,
        projectId: widget.invoice.projectId,
        instructions: info,
        bytes: proof!.bytes!,
        filename: proof!.name,
        mimeType: extension == 'pdf'
            ? 'application/pdf'
            : 'image/${extension == 'jpg' ? 'jpeg' : extension}',
        amountMinor: info.amountMinor,
        transferDate: date.text.trim(),
        senderName: sender.text.trim(),
        senderBank: bank.text.trim(),
        bankReference: reference.text.trim(),
      );
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ManualPaymentStatusScreen(record: record),
          ),
        );
      }
    } catch (value) {
      if (mounted) setState(() => error = value.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class ManualPaymentStatusScreen extends StatelessWidget {
  const ManualPaymentStatusScreen({super.key, required this.record});
  final ManualPaymentRecord record;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Transfer submission')),
    body: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(StrotSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BANK TRANSFER REVIEW',
                style: TextStyle(
                  color: StrotColors.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              Text(
                record.reference,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(paymentMoney(record.amountMinor)),
              Text(record.status.replaceAll('_', ' ')),
              const SizedBox(height: StrotSpacing.md),
              Text(
                record.reviewNote ??
                    'Your evidence is stored securely. This transfer is not treated as paid until STROT verifies the receiving-bank credit.',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
