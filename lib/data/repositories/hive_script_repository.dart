import 'dart:async';
import 'package:hive_ce/hive.dart';
import 'package:isar/isar.dart' show Isar;

import '../local/hive_service.dart';
import '../models/script.dart';
import 'script_repository.dart';

class HiveScriptRepository implements ScriptRepository {
  HiveScriptRepository(this._hive);
  final HiveService _hive;
  
  static const String _boxName = 'scripts';
  Box<Map>? _box;
  
  final _watchController = StreamController<List<Script>>.broadcast();

  Future<Box<Map>> get _getBox async {
    await _hive.init();
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Map>(_boxName);
    }
    return _box!;
  }

  Script _fromMap(Map map) {
    final s = Script()
      ..id = map['id'] as int? ?? 0
      ..uuid = map['uuid'] as String
      ..projectId = map['projectId'] as String?
      ..title = map['title'] as String
      ..content = map['content'] as String? ?? ''
      ..status = ScriptStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ScriptStatus.drafting,
      )
      ..wordCount = map['wordCount'] as int? ?? 0
      ..scrollSpeed = map['scrollSpeed'] as double?
      ..fontSize = map['fontSize'] as double?
      ..mirror = map['mirror'] as bool? ?? false
      ..focusMode = map['focusMode'] as bool? ?? true
      ..recordingPaths = (map['recordingPaths'] as List?)?.cast<String>() ?? []
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
      ..updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
      ..isArchived = map['isArchived'] as bool? ?? false;
    return s;
  }

  Map _toMap(Script s) {
    return {
      'id': s.id,
      'uuid': s.uuid,
      'projectId': s.projectId,
      'title': s.title,
      'content': s.content,
      'status': s.status.name,
      'wordCount': s.wordCount,
      'scrollSpeed': s.scrollSpeed,
      'fontSize': s.fontSize,
      'mirror': s.mirror,
      'focusMode': s.focusMode,
      'recordingPaths': s.recordingPaths,
      'createdAt': s.createdAt.millisecondsSinceEpoch,
      'updatedAt': s.updatedAt.millisecondsSinceEpoch,
      'isArchived': s.isArchived,
    };
  }

  void _notifyWatchers(Box<Map> box) {
    final all = box.values.map((m) => _fromMap(m)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _watchController.add(all);
  }

  @override
  Future<List<Script>> getAll({bool includeArchived = false}) async {
    final box = await _getBox;
    final all = box.values.map((m) => _fromMap(m)).toList();
    if (!includeArchived) {
      all.retainWhere((s) => !s.isArchived);
    }
    all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return all;
  }

  @override
  Stream<List<Script>> watchRecent({int limit = 10}) async* {
    final box = await _getBox;
    
    List<Script> getRecent() {
      final all = box.values.map((m) => _fromMap(m)).toList();
      all.retainWhere((s) => !s.isArchived);
      all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return all.take(limit).toList();
    }
    
    yield getRecent();
    
    yield* _watchController.stream.map((list) {
      final filtered = list.where((s) => !s.isArchived).toList();
      return filtered.take(limit).toList();
    });
  }

  @override
  Future<List<Script>> getByProject(String projectId) async {
    final box = await _getBox;
    final all = box.values.map((m) => _fromMap(m)).toList();
    all.retainWhere((s) => s.projectId == projectId && !s.isArchived);
    all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return all;
  }

  @override
  Future<Script?> getByUuid(String uuid) async {
    final box = await _getBox;
    final map = box.get(uuid);
    if (map != null) return _fromMap(map);
    return null;
  }

  @override
  Future<int> save(Script script) async {
    final box = await _getBox;
    script
      ..wordCount = Script.countWords(script.content)
      ..updatedAt = DateTime.now();
      
    if (script.id == Isar.autoIncrement) {
      script.id = DateTime.now().millisecondsSinceEpoch;
    }
    
    await box.put(script.uuid, _toMap(script));
    _notifyWatchers(box);
    return script.id;
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
    final box = await _getBox;
    await box.delete(uuid);
    _notifyWatchers(box);
  }
}
