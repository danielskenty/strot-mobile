import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/payments/payment_models.dart';
import '../../core/payments/payment_service.dart';
import '../../design_system/strot_tokens.dart';
import 'invoice_payment_screen.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.service,
    required this.paymentId,
  });
  final PaymentService service;
  final int paymentId;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Payment receipt')),
    body: FutureBuilder<PaymentReceipt>(
      future: service.receipt(paymentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final receipt = snapshot.data!;
        if (receipt.status == 'not_available') {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(StrotSpacing.xl),
              child: Text(
                'The official receipt is being prepared. Return after reconciliation completes.',
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'OFFICIAL PAYMENT RECORD',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Payment receipt',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: StrotSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.receiptNumber ?? 'Receipt',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      paymentMoney(receipt.amountMinor ?? 0),
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: StrotColors.gold),
                    ),
                    const Divider(),
                    Text(
                      'Method: ${receipt.paymentMethod?.replaceAll('_', ' ') ?? '—'}',
                    ),
                    Text('Transaction: ${receipt.transactionReference ?? '—'}'),
                    Text('Issued: ${receipt.issuedAt?.toLocal() ?? 'Pending'}'),
                    Text(
                      'Remaining balance: ${paymentMoney(receipt.remainingBalanceMinor ?? 0)}',
                    ),
                    if (receipt.downloadPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: StrotSpacing.lg),
                        child: ElevatedButton(
                          onPressed: () async {
                            final value = await service.receiptDownloadUrl(
                              paymentId,
                            );
                            final url = value == null
                                ? null
                                : Uri.tryParse(value);
                            if (url != null) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: const Text('Download official receipt'),
                        ),
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
}
