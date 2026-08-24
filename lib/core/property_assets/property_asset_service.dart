import '../network/api_client.dart';

class PropertyAsset {
  const PropertyAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.warrantyState,
    required this.property,
    this.manufacturer,
    this.model,
    this.serialNumber,
    this.installedOn,
    this.warrantyExpiresOn,
    this.maintenanceRequirements = const {},
  });
  final int id;
  final String name, category, status, warrantyState, property;
  final String? manufacturer,
      model,
      serialNumber,
      installedOn,
      warrantyExpiresOn;
  final Map<String, dynamic> maintenanceRequirements;
  factory PropertyAsset.fromJson(Map<String, dynamic> json) {
    final place = Map<String, dynamic>.from(json['property'] as Map);
    return PropertyAsset(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      warrantyState: json['warranty_state'] as String,
      property: place['name'] as String,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serial_number'] as String?,
      installedOn: json['installed_on'] as String?,
      warrantyExpiresOn: json['warranty_expires_on'] as String?,
      maintenanceRequirements: Map<String, dynamic>.from(
        (json['maintenance_requirements'] as Map?) ?? {},
      ),
    );
  }
}

abstract interface class PropertyAssetService {
  Future<List<PropertyAsset>> list();
}

class ApiPropertyAssetService implements PropertyAssetService {
  ApiPropertyAssetService(this.client);
  final ApiClient client;
  @override
  Future<List<PropertyAsset>> list() async =>
      ((await client.get('/property-assets'))['data'] as List)
          .map(
            (item) =>
                PropertyAsset.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
}

class MockPropertyAssetService implements PropertyAssetService {
  @override
  Future<List<PropertyAsset>> list() async => const [
    PropertyAsset(
      id: 1,
      name: 'Central air-conditioning',
      category: 'Mechanical',
      status: 'operational',
      warrantyState: 'active',
      property: 'Oak Residence',
      manufacturer: 'Daikin',
      model: 'VRV IV',
      serialNumber: 'ST-OAK-HVAC-01',
      installedOn: '2024-05-14',
      warrantyExpiresOn: '2027-05-14',
      maintenanceRequirements: {
        'Frequency': 'Quarterly',
        'Next service': '2026-09-15',
      },
    ),
  ];
}
