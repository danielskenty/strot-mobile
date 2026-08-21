import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:strot_app/core/network/api_client.dart';
import 'package:strot_app/core/sync/sync_outbox.dart';

void main() {
  test('network failure stores an operational mutation durably', () async {
    final store = MemorySyncStore();
    final client = ApiClient(
      baseUrl: 'https://strot.test/api/v1',
      httpClient: MockClient(
        (_) async => throw http.ClientException('offline'),
      ),
    );
    final outbox = SyncOutbox(client, store);
    final response = await outbox.sendOrQueue('PATCH', '/tasks/4', {
      'status': 'completed',
    });
    expect(response, isNull);
    expect(outbox.online, isFalse);
    expect((await store.read()).single.path, '/tasks/4');
  });

  test(
    'retry removes delivered changes and preserves conflicts for review',
    () async {
      var conflict = false;
      final client = ApiClient(
        baseUrl: 'https://strot.test/api/v1',
        httpClient: MockClient(
          (request) async => conflict
              ? http.Response(
                  jsonEncode({
                    'message': 'A report already exists for this date.',
                  }),
                  409,
                )
              : http.Response(
                  jsonEncode({
                    'data': {'ok': true},
                  }),
                  200,
                ),
        ),
      );
      final store = MemorySyncStore();
      final outbox = SyncOutbox(client, store);
      await outbox.enqueue('PATCH', '/tasks/4', {'status': 'completed'});
      await outbox.retryAll();
      expect(outbox.items, isEmpty);
      conflict = true;
      await outbox.enqueue('POST', '/site-reports', {'project_id': 1});
      await outbox.retryAll();
      expect(outbox.items.single.status, SyncItemStatus.needsAttention);
      expect(outbox.items.single.lastError, contains('already exists'));
    },
  );
}
