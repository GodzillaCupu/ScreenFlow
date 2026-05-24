import 'package:isar/isar.dart';

import '../local/isar_service.dart';
import '../models/project.dart';

abstract interface class ProjectRepository {
  Future<List<Project>> getAll({bool includeArchived = false});
  Stream<List<Project>> watchAll({bool includeArchived = false});
  Future<Project?> getByUuid(String uuid);
  Future<int> save(Project project);
  Future<void> setArchived(String uuid, {required bool archived});
  Future<void> delete(String uuid);
}

class IsarProjectRepository implements ProjectRepository {
  IsarProjectRepository(this._isar);
  final IsarService _isar;

  @override
  Future<List<Project>> getAll({bool includeArchived = false}) async {
    final isar = await _isar.db;
    if (includeArchived) {
      return isar.projects.where().sortByUpdatedAtDesc().findAll();
    }
    return isar.projects
        .filter()
        .isArchivedEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  @override
  Stream<List<Project>> watchAll({bool includeArchived = false}) async* {
    final isar = await _isar.db;
    yield* isar.projects
        .filter()
        .optional(!includeArchived, (q) => q.isArchivedEqualTo(false))
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<Project?> getByUuid(String uuid) async {
    final isar = await _isar.db;
    return isar.projects.filter().uuidEqualTo(uuid).findFirst();
  }

  @override
  Future<int> save(Project project) async {
    final isar = await _isar.db;
    project.updatedAt = DateTime.now();
    return isar.writeTxn(() async {
      final existing =
          await isar.projects.filter().uuidEqualTo(project.uuid).findFirst();
      if (existing != null) project.id = existing.id;
      return isar.projects.put(project);
    });
  }

  @override
  Future<void> setArchived(String uuid, {required bool archived}) async {
    final project = await getByUuid(uuid);
    if (project == null) return;
    project.isArchived = archived;
    await save(project);
  }

  @override
  Future<void> delete(String uuid) async {
    final isar = await _isar.db;
    await isar.writeTxn(() async {
      await isar.projects.filter().uuidEqualTo(uuid).deleteAll();
    });
  }
}
