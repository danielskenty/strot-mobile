import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'document_models.dart';
import '../network/api_client.dart';

abstract interface class DocumentService {
  Future<List<StrotDocument>> list();
  Future<void> upload({
    required String name,
    required Uint8List bytes,
    required String kind,
    required String caption,
  });
  Future<void> retry(int id);
}

class MockDocumentService implements DocumentService {
  static const items = [
    StrotDocument(
      id: 1,
      name: 'Scope-of-Work-v2.1.pdf',
      caption: 'Current approved scope for review.',
      sizeBytes: 1840000,
      mimeType: 'application/pdf',
      uploader: 'STROT Operations',
      status: DocumentStatus.verified,
    ),
    StrotDocument(
      id: 2,
      name: 'column-reinforcement.jpg',
      caption: 'Column C1 reinforcement before concrete pour.',
      sizeBytes: 3260000,
      mimeType: 'image/jpeg',
      uploader: 'Site Partner',
      status: DocumentStatus.submitted,
      processingStatus: DocumentProcessingStatus.extracting,
      processingProgress: 65,
    ),
    StrotDocument(
      id: 3,
      name: 'foundation-evidence.jpg',
      caption: 'Foundation inspection record.',
      sizeBytes: 2810000,
      mimeType: 'image/jpeg',
      uploader: 'Site Partner',
      status: DocumentStatus.submitted,
      processingStatus: DocumentProcessingStatus.failed,
      processingProgress: 0,
      processingMessage:
          'The file could not be processed safely. Retry or contact STROT support.',
    ),
  ];
  @override
  Future<List<StrotDocument>> list() async => items;
  @override
  Future<void> upload({
    required String name,
    required Uint8List bytes,
    required String kind,
    required String caption,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> retry(int id) async {}
}

class ApiDocumentService implements DocumentService {
  const ApiDocumentService(this.client);
  final ApiClient client;
  @override
  Future<List<StrotDocument>> list() async =>
      ((await client.get('/documents'))['data'] as List)
          .map((item) => StrotDocument.fromJson(item as Map<String, dynamic>))
          .toList();
  @override
  Future<void> retry(int id) async {
    await client.post('/documents/$id/processing/retry', {});
  }

  @override
  Future<void> upload({
    required String name,
    required Uint8List bytes,
    required String kind,
    required String caption,
  }) async {
    final mimeType = _mimeType(name);
    final checksum = base64Encode(sha256.convert(bytes).bytes);
    final session = await client.post('/media/upload-sessions', {
      'filename': name,
      'mime_type': mimeType,
      'size_bytes': bytes.length,
      'checksum': checksum,
      'module': 'documents',
      'record_id': '1',
      'project_id': 1,
      'visibility': 'project',
      'document_kind': kind,
      'caption': caption,
    });
    final data = session['data'] as Map<String, dynamic>;
    final asset = data['asset'] as Map<String, dynamic>;
    final upload = data['upload'] as Map<String, dynamic>;
    final response = await http.put(
      Uri.parse(upload['url'] as String),
      headers: (upload['headers'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      body: bytes,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'The direct S3 upload did not complete.',
        response.statusCode,
      );
    }
    await client.post('/media/${asset['id']}/complete', const {});
  }

  String _mimeType(String name) {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'csv' => 'text/csv',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls' => 'application/vnd.ms-excel',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      _ => 'application/octet-stream',
    };
  }
}
