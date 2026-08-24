import '../network/api_client.dart';

class CarePlan {
  const CarePlan({
    required this.id,
    required this.name,
    required this.frequency,
    required this.nextServiceOn,
    required this.scheduleState,
    required this.status,
    required this.property,
    required this.scope,
  });
  final int id;
  final String name, frequency, nextServiceOn, scheduleState, status, property;
  final List<String> scope;
  factory CarePlan.fromJson(Map<String, dynamic> json) => CarePlan(
    id: json['id'] as int,
    name: json['name'] as String,
    frequency: json['frequency'] as String,
    nextServiceOn: json['next_service_on'] as String,
    scheduleState: json['schedule_state'] as String,
    status: json['status'] as String,
    property: (json['property'] as Map)['name'] as String,
    scope: (json['scope'] as List).map((item) => item.toString()).toList(),
  );
}

abstract interface class CarePlanService {
  Future<List<CarePlan>> list();
}

class ApiCarePlanService implements CarePlanService {
  ApiCarePlanService(this.client);
  final ApiClient client;
  @override
  Future<List<CarePlan>> list() async =>
      ((await client.get('/care-plans'))['data'] as List)
          .map(
            (item) => CarePlan.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
}

class MockCarePlanService implements CarePlanService {
  @override
  Future<List<CarePlan>> list() async => const [
    CarePlan(
      id: 1,
      name: 'Essential Property Care',
      frequency: 'quarterly',
      nextServiceOn: '2026-09-15',
      scheduleState: 'due_soon',
      status: 'active',
      property: 'Oak Residence',
      scope: [
        'Mechanical systems inspection',
        'Electrical safety review',
        'Plumbing and water-pressure checks',
      ],
    ),
  ];
}
