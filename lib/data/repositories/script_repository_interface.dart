import '../models/script.dart';

abstract interface class ScriptRepository {
  Future<List<Script>> getAll({bool includeArchived = false});
  Stream<List<Script>> watchRecent({int limit = 10});
  Future<List<Script>> getByProject(String projectId);
  Future<Script?> getByUuid(String uuid);
  Future<int> save(Script script);
  Future<void> setArchived(String uuid, {required bool archived});
  Future<void> delete(String uuid);
}
