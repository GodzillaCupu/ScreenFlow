import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/isar_service.dart';
import '../data/models/script.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/script_repository.dart';
import '../services/audio_recorder_service.dart';
import '../services/export_service.dart';
import '../services/gemini_service.dart';
import 'config/env_config.dart';

/// ── Infrastructure / DI graph ──────────────────────────────────────────
/// One place to wire singletons. Swap an implementation here (e.g. a Hive
/// repository for web) and the whole app follows.

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final scriptRepositoryProvider = Provider<ScriptRepository>(
  (ref) => IsarScriptRepository(ref.watch(isarServiceProvider)),
);

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => IsarProjectRepository(ref.watch(isarServiceProvider)),
);

final geminiServiceProvider = Provider<GeminiService>(
  (ref) => GeminiService(
    apiKey: EnvConfig.geminiApiKey,
    model: EnvConfig.geminiModel,
  ),
);

final audioRecorderServiceProvider = Provider<AudioRecorderService>((ref) {
  final service = AudioRecorderService();
  ref.onDispose(service.dispose);
  return service;
});

final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

/// ── Cross-feature read models ──────────────────────────────────────────

/// Live "Recent Scripts" list for the dashboard.
final recentScriptsProvider = StreamProvider<List<Script>>(
  (ref) => ref.watch(scriptRepositoryProvider).watchRecent(),
);
