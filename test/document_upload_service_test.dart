import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:strot_app/core/documents/document_service.dart';
import 'package:strot_app/core/network/api_client.dart';

void main() {
  test(
    'document upload scopes its S3 session to the selected project',
    () async {
      Map<String, dynamic>? sessionBody;
      final apiHttp = MockClient((request) async {
        if (request.url.path.endsWith('/media/upload-sessions')) {
          sessionBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'data': {
                'asset': {'id': 91},
                'upload': {
                  'url': 'https://s3.test/strot/document.pdf',
                  'headers': {'Content-Type': 'application/pdf'},
                },
              },
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/media/91/complete')) {
          return http.Response('{}', 200);
        }
        return http.Response('{}', 404);
      });
      var uploadedToS3 = false;
      final uploadHttp = MockClient((request) async {
        uploadedToS3 =
            request.method == 'PUT' &&
            request.url.toString() == 'https://s3.test/strot/document.pdf';
        return http.Response('', 200);
      });
      final service = ApiDocumentService(
        ApiClient(baseUrl: 'https://api.test/api/v1', httpClient: apiHttp),
        uploadClient: uploadHttp,
      );

      await service.upload(
        projectId: 42,
        name: 'document.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
        kind: 'project_document',
        caption: 'Approved scope',
      );

      expect(sessionBody?['project_id'], 42);
      expect(sessionBody?['record_id'], '42');
      expect(sessionBody?['module'], 'documents');
      expect(uploadedToS3, isTrue);
    },
  );
}
