import '../network/api_client.dart';

class WorkOrderAdminRecord {
  const WorkOrderAdminRecord({
    required this.orders,
    required this.projects,
    required this.partners,
  });
  final List<Map<String, dynamic>> orders, projects, partners;
}

abstract interface class WorkOrderAdminService {
  Future<WorkOrderAdminRecord> load();
  Future<void> create(Map<String, dynamic> input);
  Future<void> update(int id, String action, String? note);
}

class ApiWorkOrderAdminService implements WorkOrderAdminService {
  const ApiWorkOrderAdminService(this.client);
  final ApiClient client;
  @override
  Future<WorkOrderAdminRecord> load() async {
    final data =
        (await client.get('/admin/work-orders'))['data']
            as Map<String, dynamic>;
    return WorkOrderAdminRecord(
      orders: (data['work_orders'] as List).cast<Map<String, dynamic>>(),
      projects: (data['projects'] as List).cast<Map<String, dynamic>>(),
      partners: (data['partners'] as List).cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<void> create(Map<String, dynamic> input) async {
    await client.post('/admin/work-orders', input);
  }

  @override
  Future<void> update(int id, String action, String? note) async {
    await client.patch('/admin/work-orders/$id', {
      'action': action,
      'note': note,
    });
  }
}

class MockWorkOrderAdminService implements WorkOrderAdminService {
  @override
  Future<void> update(int id, String action, String? note) async {}
  @override
  Future<WorkOrderAdminRecord> load() async => const WorkOrderAdminRecord(
    orders: [],
    projects: [
      {'id': 1, 'name': 'Oak Residence', 'reference': 'STR-24001'},
    ],
    partners: [
      {'id': 2, 'name': 'Build Partner'},
    ],
  );
  @override
  Future<void> create(Map<String, dynamic> input) async {}
}
