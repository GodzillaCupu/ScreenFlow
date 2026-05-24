import 'package:isar/isar.dart';

part 'script.g.dart';

/// A single script document. Body lives in [content]; teleprompter prefs and
/// the list of local audio recording paths travel with the script so a
/// recording session is fully reproducible offline.
@collection
class Script {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  /// uuid of the owning [Project]. Stored as a plain string (rather than an
  /// IsarLink) to keep repository queries simple and codegen-light.
  @Index()
  String? projectId;

  late String title;

  /// Full script body. The editor writes here on every debounced auto-save.
  String content = '';

  @Enumerated(EnumType.name)
  ScriptStatus status = ScriptStatus.drafting;

  int wordCount = 0;

  // Per-script teleprompter preferences (null => use global defaults).
  double? scrollSpeed;
  double? fontSize;
  bool mirror = false;
  bool focusMode = true;

  /// Absolute paths to local .m4a recordings captured for this script.
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
