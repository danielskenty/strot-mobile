enum ApprovalStatus { pending, approved, changesRequested }

class StrotApproval {
  const StrotApproval({
    required this.id,
    required this.title,
    required this.description,
    required this.version,
    required this.projectName,
    required this.projectReference,
    required this.dueAt,
    this.status = ApprovalStatus.pending,
  });
  final int id;
  final String title, description, version, projectName, projectReference;
  final DateTime dueAt;
  final ApprovalStatus status;
}
