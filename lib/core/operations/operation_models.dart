class OperationProject {
  const OperationProject({
    required this.id,
    required this.name,
    required this.reference,
  });
  final int id;
  final String name;
  final String reference;
  factory OperationProject.fromJson(Map<String, dynamic> json) =>
      OperationProject(
        id: json['id'] as int,
        name: json['name'] as String,
        reference: json['reference'] as String,
      );
}

class ProjectTask {
  const ProjectTask({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.project,
    this.dueAt,
    this.assignee,
  });
  final int id;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final DateTime? dueAt;
  final OperationProject project;
  final String? assignee;
  factory ProjectTask.fromJson(Map<String, dynamic> json) => ProjectTask(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String?,
    priority: json['priority'] as String,
    status: json['status'] as String,
    dueAt: json['due_at'] == null
        ? null
        : DateTime.parse(json['due_at'] as String),
    project: OperationProject.fromJson(json['project'] as Map<String, dynamic>),
    assignee: (json['assignee'] as Map<String, dynamic>?)?['name'] as String?,
  );
}

class DailySiteReport {
  const DailySiteReport({
    required this.id,
    required this.reportDate,
    required this.workersOnSite,
    required this.workCompleted,
    required this.status,
    required this.project,
    required this.submittedBy,
    this.weather,
    this.workPlanned,
    this.blockers,
  });
  final int id;
  final DateTime reportDate;
  final String? weather;
  final int workersOnSite;
  final String workCompleted;
  final String? workPlanned;
  final String? blockers;
  final String status;
  final OperationProject project;
  final String submittedBy;
  factory DailySiteReport.fromJson(Map<String, dynamic> json) =>
      DailySiteReport(
        id: json['id'] as int,
        reportDate: DateTime.parse(json['report_date'] as String),
        weather: json['weather'] as String?,
        workersOnSite: json['workers_on_site'] as int,
        workCompleted: json['work_completed'] as String,
        workPlanned: json['work_planned'] as String?,
        blockers: json['blockers'] as String?,
        status: json['status'] as String,
        project: OperationProject.fromJson(
          json['project'] as Map<String, dynamic>,
        ),
        submittedBy:
            (json['submitted_by'] as Map<String, dynamic>)['name'] as String,
      );
}

class NewSiteReport {
  const NewSiteReport({
    required this.projectId,
    required this.reportDate,
    required this.workersOnSite,
    required this.workCompleted,
    required this.weather,
    required this.workPlanned,
    required this.blockers,
  });
  final int projectId;
  final DateTime reportDate;
  final int workersOnSite;
  final String workCompleted;
  final String weather;
  final String workPlanned;
  final String blockers;
  Map<String, dynamic> toJson() => {
    'project_id': projectId,
    'report_date': reportDate.toIso8601String().split('T').first,
    'workers_on_site': workersOnSite,
    'work_completed': workCompleted,
    'weather': weather,
    'work_planned': workPlanned,
    'blockers': blockers,
  };
}
