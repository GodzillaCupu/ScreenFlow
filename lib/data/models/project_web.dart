class Project {
  int id = 0;

  late String uuid;
  late String title;
  String? description;
  ProjectType type = ProjectType.other;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isArchived = false;

  Project();

  Project.create({
    required this.uuid,
    required this.title,
    this.description,
    this.type = ProjectType.other,
  })  : createdAt = DateTime.now(),
        updatedAt = DateTime.now();
}

enum ProjectType {
  youtubeLongform,
  shorts,
  podcast,
  videoEssay,
  other;

  String get label => switch (this) {
        ProjectType.youtubeLongform => 'YouTube Longform',
        ProjectType.shorts => 'Shorts & TikTok',
        ProjectType.podcast => 'Podcast Outlines',
        ProjectType.videoEssay => 'Video Essay',
        ProjectType.other => 'General',
      };
}
