import '../network/api_client.dart';
import 'message_models.dart';

abstract interface class MessageService {
  Future<List<Conversation>> list();
  Future<Conversation> get(int id);
  Future<Conversation> openSupport({
    required String subject,
    required String category,
    required String priority,
    required String body,
  });
  Future<Conversation> reply(int id, String body);
  Future<Conversation> updateStatus(int id, String status);
}

class ApiMessageService implements MessageService {
  ApiMessageService(this.client);
  final ApiClient client;
  @override
  Future<List<Conversation>> list() async =>
      ((await client.get('/conversations'))['data'] as List)
          .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
          .toList();
  @override
  Future<Conversation> get(int id) async => Conversation.fromJson(
    (await client.get('/conversations/$id'))['data'] as Map<String, dynamic>,
  );
  @override
  Future<Conversation> openSupport({
    required String subject,
    required String category,
    required String priority,
    required String body,
  }) async => Conversation.fromJson(
    (await client.post('/conversations', {
          'type': 'support',
          'subject': subject,
          'category': category,
          'priority': priority,
          'body': body,
        }))['data']
        as Map<String, dynamic>,
  );
  @override
  Future<Conversation> reply(int id, String body) async =>
      Conversation.fromJson(
        (await client.post('/conversations/$id/messages', {
              'body': body,
            }))['data']
            as Map<String, dynamic>,
      );
  @override
  Future<Conversation> updateStatus(int id, String status) async =>
      Conversation.fromJson(
        (await client.patch('/conversations/$id', {'status': status}))['data']
            as Map<String, dynamic>,
      );
}

class MockMessageService implements MessageService {
  final person = const MessagePerson(id: 1, name: 'Adaeze Okafor');
  late Conversation item = Conversation(
    id: 1,
    type: 'support',
    subject: 'Document signature assistance',
    category: 'documents',
    priority: 'action_required',
    status: 'open',
    lastMessageAt: DateTime(2026, 8, 17, 10, 30),
    createdBy: person,
    assignedTo: const MessagePerson(id: 4, name: 'Amara Okoye'),
    messages: [
      StrotMessage(
        id: 1,
        body:
            'The signature control is unavailable on the current scope document.',
        createdAt: DateTime(2026, 8, 17, 10, 15),
        sender: person,
      ),
      StrotMessage(
        id: 2,
        body:
            'We are reviewing the document permissions and will update you here.',
        createdAt: DateTime(2026, 8, 17, 10, 30),
        sender: const MessagePerson(id: 4, name: 'Amara Okoye'),
      ),
    ],
  );
  @override
  Future<List<Conversation>> list() async => [item];
  @override
  Future<Conversation> get(int id) async => item;
  @override
  Future<Conversation> openSupport({
    required String subject,
    required String category,
    required String priority,
    required String body,
  }) async => item;
  @override
  Future<Conversation> reply(int id, String body) async => item;
  @override
  Future<Conversation> updateStatus(int id, String status) async => item;
}
