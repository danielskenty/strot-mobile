class ProjectIssue {
  const ProjectIssue({
    required this.id,
    required this.reference,
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
    required this.status,
    required this.projectId,
    required this.projectName,
    required this.projectReference,
    required this.createdBy,
    required this.createdAt,
    this.response,
    this.assignedTo,
    this.respondedBy,
    this.resolvedBy,
    this.impactSummary,
    this.recoveryPlan,
    this.recoveryTargetOn,
    this.recoveryStatus,
    this.recoveryOwnerId,
    this.recoveryOwner,
  });
  final int id, projectId;
  final String reference,
      category,
      priority,
      title,
      description,
      status,
      projectName,
      projectReference,
      createdBy;
  final String? response,
      assignedTo,
      respondedBy,
      resolvedBy,
      impactSummary,
      recoveryPlan,
      recoveryStatus,
      recoveryOwner;
  final int? recoveryOwnerId;
  final DateTime? recoveryTargetOn;
  final DateTime createdAt;
  factory ProjectIssue.fromJson(Map<String, dynamic> json) {
    final project = json['project'] as Map<String, dynamic>;
    return ProjectIssue(
      id: json['id'] as int,
      reference: json['reference'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      response: json['response'] as String?,
      projectId: project['id'] as int,
      projectName: project['name'] as String,
      projectReference: project['reference'] as String,
      createdBy: (json['created_by'] as Map<String, dynamic>)['name'] as String,
      assignedTo:
          (json['assigned_to'] as Map<String, dynamic>?)?['name'] as String?,
      respondedBy:
          (json['responded_by'] as Map<String, dynamic>?)?['name'] as String?,
      resolvedBy:
          (json['resolved_by'] as Map<String, dynamic>?)?['name'] as String?,
      impactSummary: json['impact_summary'] as String?,
      recoveryPlan: json['recovery_plan'] as String?,
      recoveryTargetOn: json['recovery_target_on'] == null
          ? null
          : DateTime.parse(json['recovery_target_on'] as String),
      recoveryStatus: json['recovery_status'] as String?,
      recoveryOwnerId:
          (json['recovery_owner'] as Map<String, dynamic>?)?['id'] as int?,
      recoveryOwner:
          (json['recovery_owner'] as Map<String, dynamic>?)?['name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
