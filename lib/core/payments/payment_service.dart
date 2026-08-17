import 'payment_models.dart';

abstract interface class PaymentService {
  Future<(PaymentSummary, List<StrotPayment>)> getFinance();
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
        label: 'Initial project deposit',
        amountMinor: 20000000,
        status: 'paid',
        date: DateTime(2026, 8, 4),
        reference: 'STROT-001',
      ),
      StrotPayment(
        label: 'Stage two · Scope approval',
        amountMinor: 15000000,
        status: 'due',
        date: DateTime(2026, 8, 24),
      ),
    ],
  );
}
