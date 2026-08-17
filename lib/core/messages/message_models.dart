class MessagePerson {
  const MessagePerson({required this.id, required this.name});
  final int id;
  final String name;
  factory MessagePerson.fromJson(Map<String, dynamic> json) =>
      MessagePerson(id: json['id'] as int, name: json['name'] as String);
}

class StrotMessage {
  const StrotMessage({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.sender,
  });
  final int id;
  final String body;
  final DateTime createdAt;
  final MessagePerson sender;
  factory StrotMessage.fromJson(Map<String, dynamic> json) => StrotMessage(
    id: json['id'] as int,
    body: json['body'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    sender: MessagePerson.fromJson(json['sender'] as Map<String, dynamic>),
  );
}

class Conversation {
  const Conversation({
    required this.id,
    required this.type,
    required this.subject,
    required this.priority,
    required this.status,
    required this.createdBy,
    this.category,
    this.lastMessageAt,
    this.assignedTo,
    this.messages = const [],
  });
  final int id;
  final String type;
  final String subject;
  final String? category;
  final String priority;
  final String status;
  final DateTime? lastMessageAt;
  final MessagePerson createdBy;
  final MessagePerson? assignedTo;
  final List<StrotMessage> messages;
  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] as int,
    type: json['type'] as String,
    subject: json['subject'] as String,
    category: json['category'] as String?,
    priority: json['priority'] as String,
    status: json['status'] as String,
    lastMessageAt: json['last_message_at'] == null
        ? null
        : DateTime.parse(json['last_message_at'] as String),
    createdBy: MessagePerson.fromJson(
      json['created_by'] as Map<String, dynamic>,
    ),
    assignedTo: json['assigned_to'] == null
        ? null
        : MessagePerson.fromJson(json['assigned_to'] as Map<String, dynamic>),
    messages: (json['messages'] as List<dynamic>? ?? [])
        .map((item) => StrotMessage.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}
