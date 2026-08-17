enum DocumentStatus { submitted, verified, changesRequested }

class StrotDocument {
  const StrotDocument({
    required this.id,
    required this.name,
    required this.caption,
    required this.sizeBytes,
    required this.mimeType,
    required this.uploader,
    required this.status,
  });
  final int id, sizeBytes;
  final String name, caption, mimeType, uploader;
  final DocumentStatus status;
}
