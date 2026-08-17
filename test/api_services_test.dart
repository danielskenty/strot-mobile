import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:strot_app/core/network/api_client.dart';
import 'package:strot_app/core/notifications/notification_service.dart';
import 'package:strot_app/core/projects/project_service.dart';

void main() {
  test('project service sends bearer token and parses API resources', () async {
    final transport = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer test-token');
      expect(request.url.path, '/api/v1/projects');
      return http.Response(
        '''{"data":[{"id":1,"name":"Oak Residence","reference":"STR-24001","status":"active","property":{"type":"Residential","location":"Lagos"},"summary":{"paid_minor":20000000,"currency":"NGN","pending_approvals":2,"evidence_progress":68},"milestones":[]}]}''',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = ApiProjectService(
      ApiClient(
        baseUrl: 'https://strot.test/api/v1',
        token: 'test-token',
        httpClient: transport,
      ),
    );

    final projects = await service.list();

    expect(projects.single.reference, 'STR-24001');
    expect(projects.single.summary.evidenceProgress, 68);
  });

  test('API errors preserve the response status and safe message', () async {
    final client = ApiClient(
      baseUrl: 'https://strot.test/api/v1',
      httpClient: MockClient(
        (_) async => http.Response('{"message":"Unauthenticated."}', 401),
      ),
    );

    expect(
      () => client.get('/projects'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 401)
            .having((error) => error.message, 'message', 'Unauthenticated.'),
      ),
    );
  });

  test(
    'device registrar synchronizes push token through authenticated API',
    () async {
      final transport = MockClient((request) async {
        expect(request.url.path, '/api/v1/notifications/devices');
        expect(request.headers['authorization'], 'Bearer test-token');
        expect(jsonDecode(request.body), {
          'platform': 'android',
          'token': 'fcm-token',
          'permission': 'granted',
        });
        return http.Response('{"data":{"id":19}}', 201);
      });
      final service = ApiNotificationService(
        ApiClient(
          baseUrl: 'https://strot.test/api/v1',
          token: 'test-token',
          httpClient: transport,
        ),
      );

      final id = await NotificationDeviceRegistrar(
        service,
        _PushSource(),
      ).synchronize();

      expect(id, 19);
    },
  );
}

class _PushSource implements PushTokenSource {
  @override
  Future<({String permission, String platform, String token})?>
  current() async =>
      (permission: 'granted', platform: 'android', token: 'fcm-token');
}
