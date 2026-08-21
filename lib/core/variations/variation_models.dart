class ProjectVariation {
  const ProjectVariation({
    required this.id,
    required this.reference,
    required this.title,
    required this.reason,
    required this.scopeDescription,
    required this.amountDeltaMinor,
    required this.currency,
    required this.scheduleDeltaDays,
    required this.status,
    required this.projectName,
    required this.projectReference,
    this.decisionNote,
  });
  final int id, amountDeltaMinor, scheduleDeltaDays;
  final String reference,
      title,
      reason,
      scopeDescription,
      currency,
      status,
      projectName,
      projectReference;
  final String? decisionNote;
}
