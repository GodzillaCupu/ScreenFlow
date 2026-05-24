import 'package:isar/isar.dart';

import '../local/isar_service.dart';
import '../models/script.dart';

/// Storage contract for scripts. UI/state depend on this interface only, so
/// the Isar backend can be swapped (e.g. a Hive implementation for web)
/// without touching any feature code.
abstract interface class ScriptRepository {
  Future<List<Script>> getAll({bool includeArchived = false});
  Stream<List<Script>> watchRecent({int limit = 10});
  Future<List<Script>> getByProject(String projectId);
  Future<Script?> getByUuid(String uuid);

  /// Upserts the script (by uuid), refreshing wordCount + updatedAt. Returns
  /// the Isar row id.
  Future<int> save(Script script);

  Future<void> setArchived(String uuid, {required bool archived});
  Future<void> delete(String uuid);
}

class IsarScriptRepository implements ScriptRepository {
  IsarScriptRepository(this._isar);
  final IsarService _isar;

  @override
  Future<List<Script>> getAll({bool includeArchived = false}) async {
    final isar = await _isar.db;
    final query = isar.scripts.filter();
    if (includeArchived) {
      return isar.scripts.where().findAll();
    }
    return query.isArchivedEqualTo(false).sortByUpdatedAtDesc().findAll();
  }

  @override
  Stream<List<Script>> watchRecent({int limit = 10}) async* {
    final isar = await _isar.db;
    yield* isar.scripts
        .filter()
        .isArchivedEqualTo(false)
        .sortByUpdatedAtDesc()
        .limit(limit)
        .watch(fireImmediately: true);
  }

  @override
  Future<List<Script>> getByProject(String projectId) async {
    final isar = await _isar.db;
    return isar.scripts
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .isArchivedEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  @override
  Future<Script?> getByUuid(String uuid) async {
    final isar = await _isar.db;
    return isar.scripts.filter().uuidEqualTo(uuid).findFirst();
  }

  @override
  Future<int> save(Script script) async {
    final isar = await _isar.db;
    script
      ..wordCount = Script.countWords(script.content)
      ..updatedAt = DateTime.now();
    return isar.writeTxn(() async {
      // Preserve the existing row id when updating by uuid.
      final existing =
          await isar.scripts.filter().uuidEqualTo(script.uuid).findFirst();
      if (existing != null) script.id = existing.id;
      return isar.scripts.put(script);
    });
  }

  @override
  Future<void> setArchived(String uuid, {required bool archived}) async {
    final script = await getByUuid(uuid);
    if (script == null) return;
    script.isArchived = archived;
    await save(script);
  }

  @override
  Future<void> delete(String uuid) async {
    final isar = await _isar.db;
    await isar.writeTxn(() async {
      await isar.scripts.filter().uuidEqualTo(uuid).deleteAll();
    });
  }
}
