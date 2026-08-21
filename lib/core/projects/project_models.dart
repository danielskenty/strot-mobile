class ProjectMilestone {
  const ProjectMilestone({
    required this.id,
    required this.title,
    required this.status,
    this.description,
    this.ownerLabel,
    this.dueAt,
    this.completedAt,
    this.completionNote,
    this.requirements = const [],
  });
  final int id;
  final String title, status;
  final String? description, ownerLabel, completionNote;
  final DateTime? dueAt, completedAt;
  final List<MilestoneRequirement> requirements;
  int get completedRequirements =>
      requirements.where((item) => item.complete).length;
  bool get isReady => requirements.every((item) => item.complete);
}

class MilestoneRequirement {
  const MilestoneRequirement({
    required this.key,
    required this.label,
    required this.complete,
    this.deepLink,
  });
  final String key, label;
  final bool complete;
  final String? deepLink;
}

class ProjectSummary {
  const ProjectSummary({
    required this.paidMinor,
    required this.currency,
    required this.pendingApprovals,
    required this.evidenceProgress,
    required this.approvedTotalMinor,
    required this.milestoneProgress,
  });
  final int paidMinor,
      approvedTotalMinor,
      pendingApprovals,
      evidenceProgress,
      milestoneProgress;
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
