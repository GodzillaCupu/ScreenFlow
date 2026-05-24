import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/project.dart';
import '../models/script.dart';

/// Owns the single Isar instance for the app. Opened lazily and shared via
/// the [db] future so repositories can `await` it without racing on startup.
class IsarService {
  IsarService() {
    _db = _open();
  }

  late final Future<Isar> _db;
  Future<Isar> get db => _db;

  Future<Isar> _open() async {
    if (Isar.instanceNames.isNotEmpty) {
      return Isar.getInstance()!;
    }
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [ProjectSchema, ScriptSchema],
      directory: dir.path,
      // Set false in release; the inspector is a dev-only web UI.
      inspector: true,
    );
  }
}
