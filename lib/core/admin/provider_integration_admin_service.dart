import '../network/api_client.dart';

abstract interface class ProviderIntegrationAdminService {
  Future<List<Map<String, dynamic>>> load();
  Future<void> update(int id, String status);
}

class ApiProviderIntegrationAdminService
    implements ProviderIntegrationAdminService {
  const ApiProviderIntegrationAdminService(this.client);
  final ApiClient client;
  @override
  Future<List<Map<String, dynamic>>> load() async {
    final data =
        (await client.get('/admin/provider-integrations'))['data']
            as Map<String, dynamic>;
    return (data['integrations'] as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> update(int id, String status) async {
    await client.patch('/admin/provider-integrations/$id', {'status': status});
  }
}

class MockProviderIntegrationAdminService
    implements ProviderIntegrationAdminService {
  @override
  Future<List<Map<String, dynamic>>> load() async => const [];
  @override
  Future<void> update(int id, String status) async {}
}
