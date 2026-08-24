import '../network/api_client.dart';

class BankAccountRecord {
  const BankAccountRecord({
    required this.label,
    required this.bank,
    required this.name,
    required this.number,
    required this.currency,
    required this.active,
    required this.isDefault,
    required this.instructions,
  });
  final String label, bank, name, number, currency, instructions;
  final bool active, isDefault;
  factory BankAccountRecord.fromJson(Map<String, dynamic> j) =>
      BankAccountRecord(
        label: j['label'],
        bank: j['bank_name'],
        name: j['legal_account_name'],
        number: j['account_number'],
        currency: j['currency'],
        active: j['is_active'],
        isDefault: j['is_default'],
        instructions: j['client_instructions'],
      );
}

abstract interface class BankAccountService {
  Future<List<BankAccountRecord>> list();
}

class ApiBankAccountService implements BankAccountService {
  ApiBankAccountService(this.client);
  final ApiClient client;
  @override
  Future<List<BankAccountRecord>> list() async =>
      ((await client.get('/admin/bank-accounts'))['data'] as List)
          .map(
            (x) =>
                BankAccountRecord.fromJson(Map<String, dynamic>.from(x as Map)),
          )
          .toList();
}

class MockBankAccountService implements BankAccountService {
  @override
  Future<List<BankAccountRecord>> list() async => const [
    BankAccountRecord(
      label: 'Collections',
      bank: 'STROT Bank',
      name: 'STROT LIMITED',
      number: '0123456789',
      currency: 'NGN',
      active: true,
      isDefault: true,
      instructions: 'Use the invoice payment reference.',
    ),
  ];
}
