import '../network/api_client.dart';

class ProviderDispatchRecord {
  const ProviderDispatchRecord({
    required this.requests,
    required this.providers,
  });
  final List<Map<String, dynamic>> requests, providers;
}

abstract interface class ProviderDispatchService {
  Future<ProviderDispatchRecord> load();
  Future<void> create(Map<String, dynamic> input);
  Future<void> cancel(int id, String note);
  Future<void> review(int id, String decision, String? note);
}

class ApiProviderDispatchService implements ProviderDispatchService {
  const ApiProviderDispatchService(this.client);
  final ApiClient client;
  @override
  Future<ProviderDispatchRecord> load() async {
    final data =
        (await client.get('/admin/provider-requests'))['data']
            as Map<String, dynamic>;
    return ProviderDispatchRecord(
      requests: (data['requests'] as List).cast<Map<String, dynamic>>(),
      providers: (data['providers'] as List).cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<void> create(Map<String, dynamic> input) async {
    await client.post('/admin/provider-requests', input);
  }

  @override
  Future<void> cancel(int id, String note) async {
    await client.patch('/admin/provider-requests/$id/cancel', {'note': note});
  }

  @override
  Future<void> review(int id, String decision, String? note) async {
    await client.patch('/admin/provider-requests/$id/review', {
      'decision': decision,
      'note': note,
    });
  }
}

class MockProviderDispatchService implements ProviderDispatchService {
  @override
  Future<void> review(int id, String decision, String? note) async {}
  @override
  Future<ProviderDispatchRecord> load() async => const ProviderDispatchRecord(
    requests: [],
    providers: [
      {'id': 1, 'name': 'Verification API'},
    ],
  );
  @override
  Future<void> create(Map<String, dynamic> input) async {}
  @override
  Future<void> cancel(int id, String note) async {}
}
