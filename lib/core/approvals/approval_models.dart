enum ApprovalStatus { pending, approved, changesRequested }

enum ApprovalStepStatus { waiting, pending, approved, changesRequested }

class ApprovalStep {
  const ApprovalStep({
    required this.sequence,
    required this.label,
    required this.reviewerRole,
    required this.status,
    this.reviewerName,
    this.note,
  });
  final int sequence;
  final String label;
  final String reviewerRole;
  final ApprovalStepStatus status;
  final String? reviewerName;
  final String? note;
}

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
    this.steps = const [],
    this.currentStepLabel,
    this.currentReviewerRole,
  });
  final int id;
  final String title, description, version, projectName, projectReference;
  final DateTime dueAt;
  final ApprovalStatus status;
  final List<ApprovalStep> steps;
  final String? currentStepLabel;
  final String? currentReviewerRole;
}
