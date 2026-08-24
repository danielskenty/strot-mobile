class SmartPropertySummary {
  const SmartPropertySummary({
    required this.id,
    required this.name,
    required this.reference,
    required this.location,
    required this.status,
    required this.roomsCount,
    required this.devicesCount,
    required this.onlineDevicesCount,
    required this.attentionDevicesCount,
  });
  final int id,
      roomsCount,
      devicesCount,
      onlineDevicesCount,
      attentionDevicesCount;
  final String name, reference, location, status;
  factory SmartPropertySummary.fromJson(Map<String, dynamic> json) =>
      SmartPropertySummary(
        id: json['id'] as int,
        name: json['name'] as String,
        reference: json['reference'] as String,
        location: json['location'] as String,
        status: json['status'] as String,
        roomsCount: json['rooms_count'] as int,
        devicesCount: json['devices_count'] as int,
        onlineDevicesCount: json['online_devices_count'] as int,
        attentionDevicesCount: json['attention_devices_count'] as int,
      );
}

class SmartHealthEvent {
  const SmartHealthEvent({
    required this.id,
    required this.severity,
    required this.title,
    required this.detectedAt,
    this.detail,
  });
  final int id;
  final String severity, title;
  final String? detail;
  final DateTime detectedAt;
  factory SmartHealthEvent.fromJson(Map<String, dynamic> json) =>
      SmartHealthEvent(
        id: json['id'] as int,
        severity: json['severity'] as String,
        title: json['title'] as String,
        detail: json['detail'] as String?,
        detectedAt: DateTime.parse(json['detected_at'] as String),
      );
}

class SmartDevice {
  const SmartDevice({
    required this.id,
    required this.name,
    required this.category,
    required this.connectivityStatus,
    required this.healthStatus,
    required this.capabilities,
    required this.telemetry,
    required this.healthEvents,
    this.provider,
    this.batteryPercent,
    this.lastSeenAt,
  });
  final int id;
  final String name, category, connectivityStatus, healthStatus;
  final String? provider;
  final int? batteryPercent;
  final DateTime? lastSeenAt;
  final List<String> capabilities;
  final Map<String, dynamic> telemetry;
  final List<SmartHealthEvent> healthEvents;
  factory SmartDevice.fromJson(Map<String, dynamic> json) => SmartDevice(
    id: json['id'] as int,
    name: json['name'] as String,
    category: json['category'] as String,
    provider: json['provider'] as String?,
    connectivityStatus: json['connectivity_status'] as String,
    healthStatus: json['health_status'] as String,
    batteryPercent: json['battery_percent'] as int?,
    lastSeenAt: json['last_seen_at'] == null
        ? null
        : DateTime.parse(json['last_seen_at'] as String),
    capabilities: (json['capabilities'] as List).cast<String>(),
    telemetry: Map<String, dynamic>.from(json['telemetry'] as Map),
    healthEvents: (json['health_events'] as List)
        .map((item) => SmartHealthEvent.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class SmartRoom {
  const SmartRoom({
    required this.id,
    required this.name,
    required this.devices,
    this.floor,
  });
  final int id;
  final String name;
  final String? floor;
  final List<SmartDevice> devices;
  factory SmartRoom.fromJson(Map<String, dynamic> json) => SmartRoom(
    id: json['id'] as int,
    name: json['name'] as String,
    floor: json['floor'] as String?,
    devices: (json['devices'] as List)
        .map((item) => SmartDevice.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class SmartProperty {
  const SmartProperty({
    required this.id,
    required this.name,
    required this.reference,
    required this.location,
    required this.status,
    required this.roomsCount,
    required this.devicesCount,
    required this.onlineCount,
    required this.attentionCount,
    required this.rooms,
    required this.unassignedDevices,
  });
  final int id, roomsCount, devicesCount, onlineCount, attentionCount;
  final String name, reference, location, status;
  final List<SmartRoom> rooms;
  final List<SmartDevice> unassignedDevices;
  factory SmartProperty.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    return SmartProperty(
      id: json['id'] as int,
      name: json['name'] as String,
      reference: json['reference'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      roomsCount: summary['rooms'] as int,
      devicesCount: summary['devices'] as int,
      onlineCount: summary['online'] as int,
      attentionCount: summary['attention'] as int,
      rooms: (json['rooms'] as List)
          .map((item) => SmartRoom.fromJson(item as Map<String, dynamic>))
          .toList(),
      unassignedDevices: (json['unassigned_devices'] as List)
          .map((item) => SmartDevice.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
