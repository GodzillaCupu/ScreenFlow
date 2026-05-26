import 'package:isar/isar.dart';

part 'script_native.g.dart';

@collection
class Script {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  String? projectId;

  late String title;

  String content = '';

  @Enumerated(EnumType.name)
  ScriptStatus status = ScriptStatus.drafting;

  int wordCount = 0;

  double? scrollSpeed;
  double? fontSize;
  bool mirror = false;
  bool focusMode = true;

  List<String> recordingPaths = [];

  late DateTime createdAt;
  late DateTime updatedAt;

  @Index()
  bool isArchived = false;

  Script();

  Script.create({
    required this.uuid,
    required this.title,
    this.projectId,
    this.content = '',
  })  : createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  static int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}

enum ScriptStatus {
  drafting,
  review,
  readyToRecord,
  approved;

  String get label => switch (this) {
        ScriptStatus.drafting => 'Drafting',
        ScriptStatus.review => 'Review',
        ScriptStatus.readyToRecord => 'Ready to Record',
        ScriptStatus.approved => 'Approved',
      };
}
