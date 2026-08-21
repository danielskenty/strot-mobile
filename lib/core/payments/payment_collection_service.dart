import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';
import 'payment_collection_models.dart';

class PaymentOptions {
  const PaymentOptions({
    required this.nombaEnabled,
    required this.bankEnabled,
    required this.schedule,
  });
  final bool nombaEnabled, bankEnabled;
  final List<PaymentScheduleItem> schedule;
}

abstract interface class PaymentCollectionService {
  Future<PaymentOptions> options(int invoiceId);
  Future<PaymentAttempt> createNomba(int invoiceId, {int? scheduleId});
  Future<PaymentAttempt> verify(String orderReference);
  Future<BankTransferInstructions> bankInstructions(
    int invoiceId, {
    int? scheduleId,
  });
  Future<ManualPaymentRecord> submitBankProof({
    required int invoiceId,
    required int projectId,
    required BankTransferInstructions instructions,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required int amountMinor,
    required String transferDate,
    required String senderName,
    String? senderBank,
    String? bankReference,
    String? note,
  });
  Future<ManualPaymentRecord> submission(String id);
}

class ApiPaymentCollectionService implements PaymentCollectionService {
  ApiPaymentCollectionService(this.client);
  final ApiClient client;
  @override
  Future<PaymentOptions> options(int invoiceId) async {
    final data =
        (await client.get('/invoices/$invoiceId/payment-options'))['data']
            as Map<String, dynamic>;
    final methods = data['methods'] as Map<String, dynamic>;
    return PaymentOptions(
      nombaEnabled:
          (methods['nomba'] as Map<String, dynamic>)['enabled'] as bool,
      bankEnabled:
          (methods['bank_transfer'] as Map<String, dynamic>)['enabled'] as bool,
      schedule: (data['payment_schedule'] as List<dynamic>? ?? [])
          .map((e) => PaymentScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<PaymentAttempt> createNomba(int invoiceId, {int? scheduleId}) async =>
      PaymentAttempt.fromJson(
        (await client.post('/invoices/$invoiceId/nomba-checkout', {
              'payment_schedule_id': scheduleId,
            }))['data']
            as Map<String, dynamic>,
      );
  @override
  Future<PaymentAttempt> verify(
    String orderReference,
  ) async => PaymentAttempt.fromJson(
    (await client.get(
          '/payment-attempts/by-order/${Uri.encodeComponent(orderReference)}',
        ))['data']
        as Map<String, dynamic>,
  );
  @override
  Future<BankTransferInstructions> bankInstructions(
    int invoiceId, {
    int? scheduleId,
  }) async {
    final suffix = scheduleId == null ? '' : '?payment_schedule_id=$scheduleId';
    final data =
        (await client.get(
              '/invoices/$invoiceId/bank-transfer-instructions$suffix',
            ))['data']
            as Map<String, dynamic>;
    final account = data['account'] as Map<String, dynamic>;
    return BankTransferInstructions(
      accountId: account['id'] as int,
      accountName: account['legal_account_name'] as String,
      bankName: account['bank_name'] as String,
      accountNumber: account['account_number'] as String,
      paymentReference: data['payment_reference'] as String,
      amountMinor: data['amount_minor'] as int,
      currency: data['currency'] as String,
      notice: data['verification_notice'] as String,
      scheduleId: data['payment_schedule_id'] as int?,
    );
  }

  @override
  Future<ManualPaymentRecord> submitBankProof({
    required int invoiceId,
    required int projectId,
    required BankTransferInstructions instructions,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required int amountMinor,
    required String transferDate,
    required String senderName,
    String? senderBank,
    String? bankReference,
    String? note,
  }) async {
    final checksum = base64Encode(sha256.convert(bytes).bytes);
    final session =
        (await client.post('/media/upload-sessions', {
              'filename': filename,
              'mime_type': mimeType,
              'size_bytes': bytes.length,
              'checksum': checksum,
              'module': 'payments',
              'record_id': '$invoiceId',
              'project_id': projectId,
              'visibility': 'private',
              'caption': 'Bank transfer proof',
            }))['data']
            as Map<String, dynamic>;
    final upload = session['upload'] as Map<String, dynamic>;
    final asset = session['asset'] as Map<String, dynamic>;
    final response = await http.put(
      Uri.parse(upload['url'] as String),
      headers: Map<String, String>.from(upload['headers'] as Map),
      body: bytes,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException(
        'Proof could not be uploaded to private storage.',
        422,
      );
    }
    await client.post('/media/${asset['id']}/complete', {});
    for (var attempt = 0; attempt < 30; attempt++) {
      final state =
          (await client.get('/media/${asset['id']}'))['data']
              as Map<String, dynamic>;
      if (state['status'] == 'available') break;
      if (['failed', 'rejected', 'quarantined'].contains(state['status'])) {
        throw const ApiException(
          'The proof file did not pass secure processing.',
          422,
        );
      }
      if (attempt == 29) {
        throw const ApiException(
          'The proof is still processing. Please try again shortly.',
          409,
        );
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    final result = await client
        .post('/invoices/$invoiceId/manual-payment-submissions', {
          'payment_schedule_id': instructions.scheduleId,
          'bank_account_id': instructions.accountId,
          'submitted_amount_minor': amountMinor,
          'transfer_date': transferDate,
          'sender_name': senderName,
          'sender_bank': senderBank,
          'bank_transaction_reference': bankReference,
          'proof_media_asset_id': asset['id'],
          'client_note': note,
          'declaration_accepted': true,
        });
    return ManualPaymentRecord.fromJson({
      ...result['data'] as Map<String, dynamic>,
      'invoice': {'id': invoiceId},
    });
  }

  @override
  Future<ManualPaymentRecord> submission(String id) async =>
      ManualPaymentRecord.fromJson(
        (await client.get('/manual-payment-submissions/$id'))['data']
            as Map<String, dynamic>,
      );
}
