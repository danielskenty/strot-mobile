class PropertyAccessRecord {
  const PropertyAccessRecord({
    required this.id,
    required this.type,
    required this.name,
    required this.emergencyContact,
    required this.authorizedAreas,
    required this.status,
    required this.propertyId,
    required this.propertyName,
    required this.propertyReference,
    required this.createdBy,
    this.relationship,
    this.email,
    this.phone,
    this.accessStartsAt,
    this.accessEndsAt,
    this.revokedAt,
    this.revokedBy,
  });
  final int id, propertyId;
  final String type, name, status, propertyName, propertyReference, createdBy;
  final String? relationship, email, phone, revokedBy;
  final bool emergencyContact;
  final List<String> authorizedAreas;
  final DateTime? accessStartsAt, accessEndsAt, revokedAt;
  factory PropertyAccessRecord.fromJson(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>;
    return PropertyAccessRecord(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      emergencyContact: json['emergency_contact'] as bool,
      authorizedAreas: (json['authorized_areas'] as List).cast<String>(),
      accessStartsAt: json['access_starts_at'] == null
          ? null
          : DateTime.parse(json['access_starts_at'] as String),
      accessEndsAt: json['access_ends_at'] == null
          ? null
          : DateTime.parse(json['access_ends_at'] as String),
      status: json['status'] as String,
      revokedAt: json['revoked_at'] == null
          ? null
          : DateTime.parse(json['revoked_at'] as String),
      propertyId: property['id'] as int,
      propertyName: property['name'] as String,
      propertyReference: property['reference'] as String,
      createdBy: (json['created_by'] as Map<String, dynamic>)['name'] as String,
      revokedBy:
          (json['revoked_by'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }
}
