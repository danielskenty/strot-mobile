import '../network/api_client.dart';
import 'smart_property_models.dart';

abstract interface class SmartPropertyService {
  Future<List<SmartPropertySummary>> list();
  Future<SmartProperty> get(int id);
}

class ApiSmartPropertyService implements SmartPropertyService {
  const ApiSmartPropertyService(this.client);
  final ApiClient client;
  @override
  Future<List<SmartPropertySummary>> list() async =>
      ((await client.get('/smart-properties'))['data'] as List)
          .map(
            (item) =>
                SmartPropertySummary.fromJson(item as Map<String, dynamic>),
          )
          .toList();
  @override
  Future<SmartProperty> get(int id) async => SmartProperty.fromJson(
    (await client.get('/smart-properties/$id'))['data'] as Map<String, dynamic>,
  );
}

class MockSmartPropertyService implements SmartPropertyService {
  int? lastOpenedId;
  static const summary = SmartPropertySummary(
    id: 1,
    name: 'Oak Residence',
    reference: 'PROP-24001',
    location: 'Lekki, Lagos',
    status: 'active',
    roomsCount: 1,
    devicesCount: 1,
    onlineDevicesCount: 1,
    attentionDevicesCount: 1,
  );
  static final device = SmartDevice(
    id: 41,
    name: 'Climate sensor',
    category: 'climate',
    provider: 'STROT Building Systems',
    connectivityStatus: 'online',
    healthStatus: 'attention',
    batteryPercent: 24,
    lastSeenAt: DateTime(2026, 8, 22, 15, 45),
    capabilities: const ['temperature', 'humidity'],
    telemetry: const {'temperature_c': 24.5, 'humidity_percent': 61},
    healthEvents: [
      SmartHealthEvent(
        id: 7,
        severity: 'action_required',
        title: 'Battery replacement due',
        detail: 'Replace during the next property-care visit.',
        detectedAt: DateTime(2026, 8, 22, 14),
      ),
    ],
  );
  @override
  Future<List<SmartPropertySummary>> list() async => const [summary];
  @override
  Future<SmartProperty> get(int id) async {
    lastOpenedId = id;
    return SmartProperty(
      id: 1,
      name: 'Oak Residence',
      reference: 'PROP-24001',
      location: 'Lekki, Lagos',
      status: 'active',
      roomsCount: 1,
      devicesCount: 1,
      onlineCount: 1,
      attentionCount: 1,
      rooms: [
        SmartRoom(
          id: 2,
          name: 'Living room',
          floor: 'Ground floor',
          devices: [device],
        ),
      ],
      unassignedDevices: const [],
    );
  }
}
