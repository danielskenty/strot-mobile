import '../network/api_client.dart';

class AdminProjectRecord {
  const AdminProjectRecord({
    required this.id,
    required this.name,
    required this.reference,
    required this.status,
    required this.client,
    required this.milestones,
    required this.tasks,
    required this.approvals,
    required this.documents,
  });
  final int id;
  final String name, reference, status, client;
  final List<Map<String, dynamic>> milestones, tasks, approvals, documents;
  factory AdminProjectRecord.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> rows(String key) => (json[key] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    return AdminProjectRecord(
      id: json['id'] as int,
      name: json['name'] as String,
      reference: json['reference'] as String,
      status: json['status'] as String,
      client: (json['client_organization'] as Map)['name'] as String,
      milestones: rows('milestones'),
      tasks: rows('tasks'),
      approvals: rows('approvals'),
      documents: rows('documents'),
    );
  }
}

abstract interface class AdminProjectDirectoryService {
  Future<List<AdminProjectRecord>> list();
  Future<AdminProjectRecord> get(int id);
}

class ApiAdminProjectDirectoryService implements AdminProjectDirectoryService {
  ApiAdminProjectDirectoryService(this.client);
  final ApiClient client;
  @override
  Future<List<AdminProjectRecord>> list() async =>
      ((await client.get('/admin/projects'))['data'] as List)
          .map(
            (item) => AdminProjectRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
  @override
  Future<AdminProjectRecord> get(int id) async => AdminProjectRecord.fromJson(
    Map<String, dynamic>.from(
      (await client.get('/admin/projects/$id'))['data'] as Map,
    ),
  );
}

class MockAdminProjectDirectoryService implements AdminProjectDirectoryService {
  static const project = AdminProjectRecord(
    id: 1,
    name: 'Oak Residence',
    reference: 'STR-24001',
    status: 'active',
    client: 'Oak Family',
    milestones: [
      {'title': 'Foundation', 'status': 'ready'},
    ],
    tasks: [
      {'title': 'Review programme', 'status': 'open'},
    ],
    approvals: [],
    documents: [],
  );
  @override
  Future<List<AdminProjectRecord>> list() async => const [project];
  @override
  Future<AdminProjectRecord> get(int id) async => project;
}
