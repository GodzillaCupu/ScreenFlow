import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers.dart';
import '../../../data/models/project.dart';
import '../../../data/models/script.dart';

final _uuid = Uuid();

/// Live list of project folders ("Channels") for the dashboard grid.
final projectsProvider = StreamProvider<List<Project>>(
  (ref) => ref.watch(projectRepositoryProvider).watchAll(),
);

/// Map of project uuid → number of scripts in it, for the folder cards.
/// Recomputes whenever the recent-scripts stream ticks (i.e. on any save).
final projectScriptCountsProvider = FutureProvider<Map<String, int>>(
  (ref) async {
    ref.watch(recentScriptsProvider); // invalidate on script changes
    final scripts = await ref.watch(scriptRepositoryProvider).getAll();
    final counts = <String, int>{};
    for (final s in scripts) {
      final pid = s.projectId;
      if (pid != null) counts[pid] = (counts[pid] ?? 0) + 1;
    }
    return counts;
  },
);

/// A single project folder by uuid (for the project folder screen header).
final projectByIdProvider = FutureProvider.family<Project?, String>(
  (ref, id) => ref.watch(projectRepositoryProvider).getByUuid(id),
);

/// Scripts belonging to a project. Refreshes when any script is saved.
final scriptsByProjectProvider = FutureProvider.family<List<Script>, String>(
  (ref, id) async {
    ref.watch(recentScriptsProvider); // invalidate on script changes
    return ref.watch(scriptRepositoryProvider).getByProject(id);
  },
);

/// Imperative actions invoked from the dashboard ("New Script", new folder).
final dashboardActionsProvider = Provider<DashboardActions>(
  (ref) => DashboardActions(ref),
);

class DashboardActions {
  DashboardActions(this._ref);
  final Ref _ref;

  /// Creates a blank script (optionally inside a project) and returns its uuid
  /// so the caller can navigate straight into the editor.
  Future<String> createScript({String? projectId, String? title}) async {
    final script = Script.create(
      uuid: _uuid.v4(),
      title: title ?? 'Untitled Script',
      projectId: projectId,
    );
    await _ref.read(scriptRepositoryProvider).save(script);
    return script.uuid;
  }

  Future<String> createProject({
    required String title,
    ProjectType type = ProjectType.other,
  }) async {
    final project = Project.create(uuid: _uuid.v4(), title: title, type: type);
    await _ref.read(projectRepositoryProvider).save(project);
    return project.uuid;
  }
}
