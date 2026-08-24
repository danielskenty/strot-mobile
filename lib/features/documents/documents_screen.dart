import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/documents/document_models.dart';
import '../../core/documents/document_service.dart';
import '../../core/projects/project_models.dart';
import '../../core/projects/project_service.dart';
import '../../design_system/strot_tokens.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({
    super.key,
    required this.service,
    required this.projectService,
    this.reviewMode = false,
  });
  final DocumentService service;
  final ProjectService projectService;
  final bool reviewMode;
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool uploading = false;
  bool uploaded = false;
  String? error;
  int? selectedProjectId;
  late final Future<List<StrotProject>> projectOptions;

  @override
  void initState() {
    super.initState();
    projectOptions = widget.projectService.list();
  }

  Future<void> pickAndUpload() async {
    final projectId = selectedProjectId;
    if (projectId == null) {
      setState(() => error = 'Select the project this document belongs to.');
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null || !mounted) return;
    final caption = TextEditingController();
    String kind = 'project_document';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload project document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: StrotSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: kind,
                decoration: const InputDecoration(labelText: 'Document type'),
                items: const [
                  DropdownMenuItem(
                    value: 'project_document',
                    child: Text('Project document'),
                  ),
                  DropdownMenuItem(
                    value: 'evidence',
                    child: Text('Site evidence'),
                  ),
                  DropdownMenuItem(
                    value: 'payment_evidence',
                    child: Text('Payment evidence'),
                  ),
                ],
                onChanged: (value) => setDialogState(() => kind = value!),
              ),
              const SizedBox(height: StrotSpacing.md),
              TextField(
                controller: caption,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Caption'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) {
      caption.dispose();
      return;
    }
    setState(() => uploading = true);
    try {
      await widget.service.upload(
        projectId: projectId,
        name: file.name,
        bytes: file.bytes!,
        kind: kind,
        caption: caption.text.trim(),
      );
    } catch (exception) {
      if (mounted) {
        setState(() {
          uploading = false;
          error = exception.toString();
        });
      }
      caption.dispose();
      return;
    }
    caption.dispose();
    if (mounted) {
      setState(() {
        uploading = false;
        uploaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<StrotDocument>>(
    future: widget.service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          if (error != null)
            Container(
              padding: const EdgeInsets.all(StrotSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: StrotColors.gold),
                color: StrotColors.goldMuted,
              ),
              child: Text('◇ $error'),
            ),
          if (error != null) const SizedBox(height: StrotSpacing.lg),
          if (uploaded)
            Container(
              padding: const EdgeInsets.all(StrotSpacing.md),
              decoration: const BoxDecoration(
                color: StrotColors.goldMuted,
                border: Border(
                  left: BorderSide(color: StrotColors.gold, width: 2),
                ),
              ),
              child: const Text(
                '✓ Upload received and added to the project review queue.',
              ),
            ),
          if (uploaded) const SizedBox(height: StrotSpacing.lg),
          Text(
            widget.reviewMode
                ? 'S3 DOCUMENT CONTROL'
                : 'CONTROLLED PROJECT RECORDS',
            style: const TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            widget.reviewMode
                ? 'Document and evidence review'
                : 'Document centre',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: StrotSpacing.sm),
          Text(
            widget.reviewMode
                ? 'Resolve review-ready evidence and processing exceptions.'
                : 'Access current documents and submit evidence against your project.',
          ),
          const SizedBox(height: StrotSpacing.lg),
          if (!widget.reviewMode)
            FutureBuilder<List<StrotProject>>(
              future: projectOptions,
              builder: (context, projectSnapshot) {
                final projects = projectSnapshot.data ?? const <StrotProject>[];
                if (projectSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                if (projectSnapshot.hasError) {
                  return const Text(
                    'Projects could not be loaded. Document upload is unavailable.',
                  );
                }
                if (projects.isEmpty) {
                  return const Text(
                    'No authorized projects are available for document upload.',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      key: const Key('document-project-select'),
                      initialValue: selectedProjectId,
                      decoration: const InputDecoration(labelText: 'Project'),
                      items: projects
                          .map(
                            (project) => DropdownMenuItem(
                              value: project.id,
                              child: Text(
                                '${project.name} · ${project.reference}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: uploading
                          ? null
                          : (value) => setState(() {
                              selectedProjectId = value;
                              error = null;
                            }),
                    ),
                    const SizedBox(height: StrotSpacing.md),
                    ElevatedButton.icon(
                      onPressed: uploading || selectedProjectId == null
                          ? null
                          : pickAndUpload,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        uploading ? 'Uploading securely…' : 'Upload document',
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.data!.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.md),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(StrotSpacing.md),
                      leading: Icon(
                        item.mimeType == 'application/pdf'
                            ? Icons.description_outlined
                            : Icons.image_outlined,
                        color: StrotColors.gold,
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.caption}\n${_size(item.sizeBytes)} · ${item.uploader}',
                      ),
                      isThreeLine: true,
                      trailing: _Status(status: item.processingStatus),
                    ),
                    LinearProgressIndicator(
                      value: item.processingProgress / 100,
                      backgroundColor: StrotColors.forestMuted,
                      color: StrotColors.gold,
                    ),
                    const SizedBox(height: StrotSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.processingMessage ??
                                _processingLabel(item.processingStatus),
                            style: const TextStyle(
                              color: StrotColors.charcoalMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (item.processingStatus ==
                            DocumentProcessingStatus.failed)
                          TextButton(
                            onPressed: () async {
                              await widget.service.retry(item.id);
                              if (mounted) setState(() {});
                            },
                            child: const Text('Retry'),
                          ),
                      ],
                    ),
                    if (widget.reviewMode &&
                        item.processingStatus ==
                            DocumentProcessingStatus.ready &&
                        item.status == DocumentStatus.submitted)
                      Padding(
                        padding: const EdgeInsets.only(top: StrotSpacing.md),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _review(item),
                            child: const Text('Record review decision'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  Future<void> _review(StrotDocument item) async {
    final note = TextEditingController();
    var decision = 'verified';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Accountable evidence review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: decision,
                decoration: const InputDecoration(labelText: 'Decision'),
                items: const [
                  DropdownMenuItem(
                    value: 'verified',
                    child: Text('Verify evidence'),
                  ),
                  DropdownMenuItem(
                    value: 'changes_requested',
                    child: Text('Return for correction'),
                  ),
                ],
                onChanged: (value) => setDialogState(() => decision = value!),
              ),
              const SizedBox(height: StrotSpacing.md),
              TextField(
                controller: note,
                maxLines: 3,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Review note',
                  helperText: 'Required when returning for correction',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  decision == 'changes_requested' && note.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Record decision'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await widget.service.review(item.id, decision, note.text.trim());
      if (mounted) setState(() {});
    }
    note.dispose();
  }

  String _size(int bytes) => bytes < 1000000
      ? '${(bytes / 1000).round()} KB'
      : '${(bytes / 1000000).toStringAsFixed(1)} MB';
  String _processingLabel(DocumentProcessingStatus status) => switch (status) {
    DocumentProcessingStatus.queued => 'Queued securely',
    DocumentProcessingStatus.scanning => 'Running integrity and safety checks',
    DocumentProcessingStatus.extracting => 'Preparing preview and metadata',
    DocumentProcessingStatus.ready => 'Ready for accountable review',
    DocumentProcessingStatus.failed => 'Processing failed',
    DocumentProcessingStatus.quarantined => 'Held after integrity check',
  };
}

class _Status extends StatelessWidget {
  const _Status({required this.status});
  final DocumentProcessingStatus status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: StrotSpacing.sm,
      vertical: StrotSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: StrotColors.goldMuted,
      border: Border.all(color: StrotColors.gold),
    ),
    child: Text(
      status.name,
      style: const TextStyle(
        color: StrotColors.forest,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
