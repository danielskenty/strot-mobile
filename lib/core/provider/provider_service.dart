import '../network/api_client.dart';

class ProviderJob {
  const ProviderJob({
    required this.id,
    required this.reference,
    required this.service,
    required this.summary,
    required this.status,
    required this.payload,
    this.dueAt,
    this.result,
  });
  final int id;
  final String reference, service, summary, status;
  final DateTime? dueAt;
  final Map<String, dynamic> payload;
  final Map<String, dynamic>? result;
  factory ProviderJob.fromJson(Map<String, dynamic> json) => ProviderJob(
    id: json['id'] as int,
    reference: json['reference'] as String,
    service: json['service'] as String,
    summary: json['summary'] as String,
    status: json['status'] as String,
    dueAt: json['due_at'] == null
        ? null
        : DateTime.parse(json['due_at'] as String),
    payload: Map<String, dynamic>.from(json['payload'] as Map),
    result: json['result'] == null
        ? null
        : Map<String, dynamic>.from(json['result'] as Map),
  );
}

class ProviderIntegrationHealth {
  const ProviderIntegrationHealth({
    required this.id,
    required this.name,
    required this.environment,
    required this.status,
    this.latencyMs,
    this.consecutiveFailures = 0,
    this.openIncidents = 0,
    this.capabilities = const [],
  });
  final int id;
  final String name, environment, status;
  final int? latencyMs;
  final int consecutiveFailures, openIncidents;
  final List<String> capabilities;
}

class ProviderOperations {
  const ProviderOperations({required this.jobs, required this.integrations});
  final List<ProviderJob> jobs;
  final List<ProviderIntegrationHealth> integrations;
}

abstract interface class ProviderService {
  Future<ProviderOperations> list();
  Future<void> transition(int id, String status, {Map<String, String>? result});
  Future<void> reportHealth(
    int id,
    String status, {
    int? latencyMs,
    String? errorCode,
    String? message,
  });
}

class ApiProviderService implements ProviderService {
  ApiProviderService(this.client);
  final ApiClient client;
  @override
  Future<ProviderOperations> list() async {
    final data =
        (await client.get('/provider/operations'))['data']
            as Map<String, dynamic>;
    return ProviderOperations(
      jobs: (data['requests'] as List)
          .map((item) => ProviderJob.fromJson(item as Map<String, dynamic>))
          .toList(),
      integrations: (data['integrations'] as List).map((item) {
        final value = item as Map<String, dynamic>;
        return ProviderIntegrationHealth(
          id: value['id'] as int,
          name: value['name'] as String,
          environment: value['environment'] as String,
          status: value['status'] as String,
          latencyMs: value['latency_ms'] as int?,
          consecutiveFailures: value['consecutive_failures'] as int? ?? 0,
          openIncidents: value['open_incidents_count'] as int? ?? 0,
          capabilities: (value['capabilities'] as List<dynamic>? ?? [])
              .cast<String>(),
        );
      }).toList(),
    );
  }

  @override
  Future<void> transition(
    int id,
    String status, {
    Map<String, String>? result,
  }) async => client.patch('/provider/requests/$id', {
    'status': status,
    ...result == null ? const <String, dynamic>{} : {'result': result},
  });
  @override
  Future<void> reportHealth(
    int id,
    String status, {
    int? latencyMs,
    String? errorCode,
    String? message,
  }) async => client.post('/provider/integrations/$id/health-events', {
    'status': status,
    'latency_ms': latencyMs,
    'error_code': errorCode,
    'safe_message': message,
  });
}

class MockProviderService implements ProviderService {
  @override
  Future<ProviderOperations> list() async => const ProviderOperations(
    jobs: [
      ProviderJob(
        id: 1,
        reference: 'API-24001',
        service: 'Property verification',
        summary: 'Verify title and coordinate match for Oak Residence.',
        status: 'pending',
        payload: {'property_reference': 'PROP-001'},
      ),
    ],
    integrations: [
      ProviderIntegrationHealth(
        id: 1,
        name: 'Property Verification',
        environment: 'production',
        status: 'operational',
        latencyMs: 284,
      ),
    ],
  );
  @override
  Future<void> transition(
    int id,
    String status, {
    Map<String, String>? result,
  }) async {}
  @override
  Future<void> reportHealth(
    int id,
    String status, {
    int? latencyMs,
    String? errorCode,
    String? message,
  }) async {}
}
