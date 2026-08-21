class InspectionCheck {
  const InspectionCheck({
    required this.key,
    required this.label,
    required this.complete,
    this.note,
  });
  final String key, label;
  final bool complete;
  final String? note;
}

class SiteInspection {
  const SiteInspection({
    required this.id,
    required this.reference,
    required this.title,
    required this.location,
    required this.scheduledAt,
    required this.status,
    required this.projectName,
    required this.projectReference,
    required this.assigneeName,
    required this.checklist,
    required this.evidenceNames,
    this.instructions,
    this.findings,
    this.reviewNote,
  });
  final int id;
  final String reference,
      title,
      location,
      status,
      projectName,
      projectReference,
      assigneeName;
  final DateTime scheduledAt;
  final String? instructions, findings, reviewNote;
  final List<InspectionCheck> checklist;
  final List<String> evidenceNames;
  int get complete => checklist.where((item) => item.complete).length;
}
