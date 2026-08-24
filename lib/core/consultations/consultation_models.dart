class ClientConsultation {
  const ClientConsultation({
    required this.id,
    required this.reference,
    required this.service,
    required this.propertyType,
    required this.location,
    required this.brief,
    required this.status,
    required this.createdAt,
    this.preferredDate,
    this.scheduledAt,
    this.meetingUrl,
    this.clientActionNote,
    this.clientActionAt,
    this.advisorName,
  });

  final int id;
  final String reference, service, propertyType, location, brief, status;
  final String? preferredDate, meetingUrl, clientActionNote, advisorName;
  final DateTime? scheduledAt, clientActionAt;
  final DateTime createdAt;

  factory ClientConsultation.fromJson(Map<String, dynamic> json) {
    final advisor = json['assigned_to'] as Map<String, dynamic>?;
    return ClientConsultation(
      id: json['id'] as int,
      reference: json['reference'] as String,
      service: json['service'] as String,
      propertyType: json['property_type'] as String,
      location: json['location'] as String,
      brief: json['brief'] as String,
      status: json['status'] as String,
      preferredDate: json['preferred_date'] as String?,
      scheduledAt: json['scheduled_at'] == null
          ? null
          : DateTime.parse(json['scheduled_at'] as String),
      meetingUrl: json['meeting_url'] as String?,
      clientActionNote: json['client_action_note'] as String?,
      clientActionAt: json['client_action_at'] == null
          ? null
          : DateTime.parse(json['client_action_at'] as String),
      advisorName: advisor?['name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
