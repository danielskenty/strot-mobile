enum DocumentStatus { submitted, verified, changesRequested }

enum DocumentProcessingStatus {
  queued,
  scanning,
  extracting,
  ready,
  failed,
  quarantined,
}

class StrotDocument {
  const StrotDocument({
    required this.id,
    required this.name,
    required this.caption,
    required this.sizeBytes,
    required this.mimeType,
    required this.uploader,
    required this.status,
    this.processingStatus = DocumentProcessingStatus.ready,
    this.processingProgress = 100,
    this.processingMessage,
  });
  final int id, sizeBytes;
  final String name, caption, mimeType, uploader;
  final DocumentStatus status;
  final DocumentProcessingStatus processingStatus;
  final int processingProgress;
  final String? processingMessage;

  factory StrotDocument.fromJson(Map<String, dynamic> json) {
    final processing = json['processing'] as Map<String, dynamic>;
    return StrotDocument(
      id: json['id'] as int,
      name: json['name'] as String,
      caption: json['caption'] as String? ?? '',
      sizeBytes: json['size_bytes'] as int,
      mimeType: json['mime_type'] as String,
      uploader: (json['uploaded_by'] as Map<String, dynamic>)['name'] as String,
      status: _status(json['status'] as String),
      processingStatus: _processing(processing['status'] as String),
      processingProgress: processing['progress'] as int,
      processingMessage: processing['message'] as String?,
    );
  }

  static DocumentStatus _status(String value) => value == 'verified'
      ? DocumentStatus.verified
      : value == 'changes_requested'
      ? DocumentStatus.changesRequested
      : DocumentStatus.submitted;
  static DocumentProcessingStatus _processing(String value) =>
      DocumentProcessingStatus.values.firstWhere(
        (item) => item.name == value,
        orElse: () => DocumentProcessingStatus.queued,
      );
}
