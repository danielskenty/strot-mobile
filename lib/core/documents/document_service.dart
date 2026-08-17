import 'dart:typed_data';
import 'document_models.dart';

abstract interface class DocumentService {
  Future<List<StrotDocument>> list();
  Future<void> upload({
    required String name,
    required Uint8List bytes,
    required String kind,
    required String caption,
  });
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
}
