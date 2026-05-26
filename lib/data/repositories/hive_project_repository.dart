import 'dart:async';
import 'package:hive_ce/hive.dart';

import '../local/hive_service.dart';
import '../models/project.dart';
import 'project_repository_interface.dart';

class HiveProjectRepository implements ProjectRepository {
  HiveProjectRepository(this._hive);
  final HiveService _hive;
  
  static const String _boxName = 'projects';
  Box<Map>? _box;
  
  // A broadcast controller to emulate Isar's watch feature.
  final _watchController = StreamController<List<Project>>.broadcast();

  Future<Box<Map>> get _getBox async {
    await _hive.init();
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Map>(_boxName);
    }
    return _box!;
  }

  Project _fromMap(Map map) {
    final p = Project()
      ..id = map['id'] as int? ?? 0
      ..uuid = map['uuid'] as String
      ..title = map['title'] as String
      ..description = map['description'] as String?
      ..type = ProjectType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ProjectType.other,
      )
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
      ..updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
      ..isArchived = map['isArchived'] as bool? ?? false;
    return p;
  }

  Map _toMap(Project p) {
    return {
      'id': p.id,
      'uuid': p.uuid,
      'title': p.title,
      'description': p.description,
      'type': p.type.name,
      'createdAt': p.createdAt.millisecondsSinceEpoch,
      'updatedAt': p.updatedAt.millisecondsSinceEpoch,
      'isArchived': p.isArchived,
    };
  }

  void _notifyWatchers(Box<Map> box) {
    final all = box.values.map((m) => _fromMap(m)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _watchController.add(all);
  }

  @override
  Future<List<Project>> getAll({bool includeArchived = false}) async {
    final box = await _getBox;
    final all = box.values.map((m) => _fromMap(m)).toList();
    if (!includeArchived) {
      all.retainWhere((p) => !p.isArchived);
    }
    all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return all;
  }

  @override
  Stream<List<Project>> watchAll({bool includeArchived = false}) async* {
    final box = await _getBox;
    // initial yield
    yield await getAll(includeArchived: includeArchived);
    
    // listen to updates
    yield* _watchController.stream.map((list) {
      if (!includeArchived) {
        return list.where((p) => !p.isArchived).toList();
      }
      return list;
    });
  }

  @override
  Future<Project?> getByUuid(String uuid) async {
    final box = await _getBox;
    final map = box.get(uuid);
    if (map != null) return _fromMap(map);
    return null;
  }

  @override
  Future<int> save(Project project) async {
    final box = await _getBox;
    project.updatedAt = DateTime.now();
    
    // Simulate auto-increment ID if needed, though UUID is primary key.
    if (project.id == 0) {
      project.id = DateTime.now().millisecondsSinceEpoch;
    }
    
    await box.put(project.uuid, _toMap(project));
    _notifyWatchers(box);
    return project.id;
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
    final box = await _getBox;
    await box.delete(uuid);
    _notifyWatchers(box);
  }
}
