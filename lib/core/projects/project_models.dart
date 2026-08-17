class ProjectMilestone {
  const ProjectMilestone({
    required this.title,
    required this.status,
    this.dueAt,
  });
  final String title, status;
  final DateTime? dueAt;
}

class ProjectSummary {
  const ProjectSummary({
    required this.paidMinor,
    required this.currency,
    required this.pendingApprovals,
    required this.evidenceProgress,
  });
  final int paidMinor, pendingApprovals, evidenceProgress;
  final String currency;
}

class StrotProject {
  const StrotProject({
    required this.id,
    required this.name,
    required this.reference,
    required this.status,
    required this.type,
    required this.location,
    required this.summary,
    required this.milestones,
  });
  final int id;
  final String name, reference, status, type, location;
  final ProjectSummary summary;
  final List<ProjectMilestone> milestones;
}
