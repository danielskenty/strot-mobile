import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:strot_app/core/network/api_client.dart';
import 'package:strot_app/core/payments/payment_admin_service.dart';
import 'package:strot_app/core/payments/payment_collection_service.dart';
import 'package:strot_app/core/payments/payment_service.dart';

void main() {
  test(
    'Nomba checkout sends selected instalment and parses server-owned attempt',
    () async {
      final transport = MockClient((request) async {
        expect(request.url.path, '/api/v1/invoices/7/nomba-checkout');
        expect(jsonDecode(request.body), {'payment_schedule_id': 12});
        return http.Response(
          '{"data":{"id":"attempt-1","invoice_id":7,"expected_amount_minor":250000,"currency":"NGN","status":"checkout_created","provider_order_reference":"order-1","checkout_url":"https://checkout.nomba.test/order-1"}}',
          201,
        );
      });
      final service = ApiPaymentCollectionService(
        ApiClient(
          baseUrl: 'https://strot.test/api/v1',
          token: 'token',
          httpClient: transport,
        ),
      );
      final attempt = await service.createNomba(7, scheduleId: 12);
      expect(attempt.orderReference, 'order-1');
      expect(attempt.amountMinor, 250000);
    },
  );

  test(
    'Nomba verification reads server status rather than callback state',
    () async {
      final transport = MockClient((request) async {
        expect(request.url.path, '/api/v1/payment-attempts/by-order/order-1');
        return http.Response(
          '{"data":{"id":"attempt-1","invoice_id":7,"expected_amount_minor":250000,"currency":"NGN","status":"succeeded","provider_order_reference":"order-1","checkout_url":null}}',
          200,
        );
      });
      final service = ApiPaymentCollectionService(
        ApiClient(baseUrl: 'https://strot.test/api/v1', httpClient: transport),
      );
      expect((await service.verify('order-1')).status, 'succeeded');
    },
  );

  test('receipt service preserves issued financial record', () async {
    final transport = MockClient(
      (request) async => http.Response(
        '{"data":{"status":"issued","receipt_number":"RCT-001","amount_minor":500000,"currency":"NGN","payment_method":"bank_transfer","transaction_reference":"BANK-1","remaining_balance_minor":100000,"issued_at":"2026-08-21T10:00:00Z","download_path":"/api/v1/media/a/download"}}',
        200,
      ),
    );
    final receipt = await ApiPaymentService(
      ApiClient(baseUrl: 'https://strot.test/api/v1', httpClient: transport),
    ).receipt(4);
    expect(receipt.receiptNumber, 'RCT-001');
    expect(receipt.remainingBalanceMinor, 100000);
  });

  test(
    'admin confirmation includes declaration and confirmed bank values',
    () async {
      final transport = MockClient((request) async {
        expect(request.url.path, '/api/v1/admin/payment-reviews/sub-1');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['action'], 'confirm');
        expect(body['confirmed_amount_minor'], 300000);
        expect(body['confirmation_declaration'], true);
        return http.Response('{"data":{}}', 200);
      });
      final service = ApiPaymentAdminService(
        ApiClient(baseUrl: 'https://strot.test/api/v1', httpClient: transport),
      );
      await service.decide(
        'sub-1',
        'confirm',
        note: 'Verified against receiving account.',
        confirmedAmountMinor: 300000,
        bankCreditDate: '2026-08-21',
        confirmedReference: 'BANK-2',
        declaration: true,
      );
    },
  );

  test('refund processing records the external provider reference', () async {
    final transport = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(jsonDecode(request.body), {
        'status': 'processed',
        'provider_reference': 'NOMBA-REF-1',
      });
      return http.Response('{"data":{}}', 200);
    });
    await ApiPaymentAdminService(
      ApiClient(baseUrl: 'https://strot.test/api/v1', httpClient: transport),
    ).transitionRefund(9, 'processed', providerReference: 'NOMBA-REF-1');
  });
}
