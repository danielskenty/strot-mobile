class ProjectJournalProject {
  const ProjectJournalProject({
    required this.id,
    required this.name,
    required this.reference,
  });
  final int id;
  final String name, reference;

  factory ProjectJournalProject.fromJson(Map<String, dynamic> json) =>
      ProjectJournalProject(
        id: json['id'] as int,
        name: json['name'] as String,
        reference: json['reference'] as String,
      );
}

class ProjectJournalEntry {
  const ProjectJournalEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.status,
    required this.occurredAt,
    required this.project,
    required this.deepLink,
    required this.certified,
    this.secondary,
    this.actor,
  });
  final String id, type, title, summary, status, deepLink;
  final String? secondary, actor;
  final DateTime occurredAt;
  final ProjectJournalProject project;
  final bool certified;

  factory ProjectJournalEntry.fromJson(Map<String, dynamic> json) =>
      ProjectJournalEntry(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        status: json['status'] as String,
        occurredAt: DateTime.parse(json['occurred_at'] as String),
        project: ProjectJournalProject.fromJson(
          json['project'] as Map<String, dynamic>,
        ),
        deepLink: json['deep_link'] as String,
        certified: json['certified'] as bool,
        secondary: json['secondary'] as String?,
        actor: json['actor'] as String?,
      );
}

class ProjectJournalSummary {
  const ProjectJournalSummary({
    required this.total,
    required this.certified,
    required this.siteUpdates,
    required this.inspections,
  });
  final int total, certified, siteUpdates, inspections;
  factory ProjectJournalSummary.fromJson(Map<String, dynamic> json) =>
      ProjectJournalSummary(
        total: json['total'] as int,
        certified: json['certified'] as int,
        siteUpdates: json['site_updates'] as int,
        inspections: json['inspections'] as int,
      );
}

class ProjectJournal {
  const ProjectJournal({
    required this.projects,
    required this.entries,
    required this.summary,
  });
  final List<ProjectJournalProject> projects;
  final List<ProjectJournalEntry> entries;
  final ProjectJournalSummary summary;
  factory ProjectJournal.fromJson(Map<String, dynamic> json) => ProjectJournal(
    projects: (json['projects'] as List)
        .map(
          (item) =>
              ProjectJournalProject.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
    entries: (json['entries'] as List)
        .map(
          (item) => ProjectJournalEntry.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
    summary: ProjectJournalSummary.fromJson(
      json['summary'] as Map<String, dynamic>,
    ),
  );
}
