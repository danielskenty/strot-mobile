import '../network/api_client.dart';
import 'payment_models.dart';

abstract interface class PaymentService {
  Future<(PaymentSummary, List<StrotPayment>)> getFinance();
  Future<PaymentReceipt> receipt(int paymentId);
  Future<String?> receiptDownloadUrl(int paymentId);
}

class MockPaymentService implements PaymentService {
  @override
  Future<(PaymentSummary, List<StrotPayment>)> getFinance() async => (
    const PaymentSummary(
      approvedMinor: 50000000,
      paidMinor: 20000000,
      outstandingMinor: 30000000,
    ),
    [
      StrotPayment(
        id: 1,
        label: 'Initial project deposit',
        amountMinor: 20000000,
        currency: 'NGN',
        status: 'paid',
        date: DateTime(2026, 8, 4),
        reference: 'STROT-001',
      ),
      StrotPayment(
        id: 2,
        label: 'Stage two · Scope approval',
        amountMinor: 15000000,
        currency: 'NGN',
        status: 'due',
        date: DateTime(2026, 8, 24),
      ),
    ],
  );
  @override
  Future<PaymentReceipt> receipt(int paymentId) async => const PaymentReceipt(
    status: 'issued',
    receiptNumber: 'STR-RCT-001',
    amountMinor: 20000000,
    currency: 'NGN',
    paymentMethod: 'bank_transfer',
    transactionReference: 'STROT-001',
    remainingBalanceMinor: 30000000,
  );
  @override
  Future<String?> receiptDownloadUrl(int paymentId) async => null;
}

class ApiPaymentService implements PaymentService {
  ApiPaymentService(this.client);
  final ApiClient client;
  @override
  Future<(PaymentSummary, List<StrotPayment>)> getFinance() async {
    final result = await client.get('/payments');
    final raw = result['data'] as List<dynamic>;
    final items = raw.map((value) {
      final item = value as Map<String, dynamic>;
      return StrotPayment(
        id: item['id'] as int,
        label: item['label'] as String,
        amountMinor: item['amount_minor'] as int,
        currency: item['currency'] as String,
        status: item['status'] as String,
        date: item['paid_at'] != null
            ? DateTime.parse(item['paid_at'] as String)
            : item['due_at'] != null
            ? DateTime.parse(item['due_at'] as String)
            : null,
        reference: item['reference'] as String?,
      );
    }).toList();
    final approved = items.fold<int>(0, (sum, item) => sum + item.amountMinor);
    final paid = items
        .where((item) => item.status == 'paid')
        .fold<int>(0, (sum, item) => sum + item.amountMinor);
    return (
      PaymentSummary(
        approvedMinor: approved,
        paidMinor: paid,
        outstandingMinor: approved - paid,
      ),
      items,
    );
  }

  @override
  Future<PaymentReceipt> receipt(int paymentId) async =>
      PaymentReceipt.fromJson(
        (await client.get('/payments/$paymentId/receipt'))['data']
            as Map<String, dynamic>,
      );

  @override
  Future<String?> receiptDownloadUrl(int paymentId) async {
    final record = await receipt(paymentId);
    final match = RegExp(
      r'/media/([^/]+)/download',
    ).firstMatch(record.downloadPath ?? '');
    if (match == null) return null;
    final response = await client.get('/media/${match.group(1)}/download-url');
    return (response['data'] as Map<String, dynamic>)['url'] as String?;
  }
}
