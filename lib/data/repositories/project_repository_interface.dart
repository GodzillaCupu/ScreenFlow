import '../models/project.dart';

abstract interface class ProjectRepository {
  Future<List<Project>> getAll({bool includeArchived = false});
  Stream<List<Project>> watchAll({bool includeArchived = false});
  Future<Project?> getByUuid(String uuid);
  Future<int> save(Project project);
  Future<void> setArchived(String uuid, {required bool archived});
  Future<void> delete(String uuid);
}
