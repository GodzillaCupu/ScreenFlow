import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/hive_service.dart';
import '../data/models/script.dart';
import '../data/repositories/hive_project_repository.dart';
import '../data/repositories/hive_script_repository.dart';
import '../data/repositories/project_repository_interface.dart';
import '../data/repositories/script_repository_interface.dart';
import '../services/audio_recorder_service.dart';
import '../services/export_service.dart';
import '../services/gemini_service.dart';
import 'config/env_config.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

final scriptRepositoryProvider = Provider<ScriptRepository>(
  (ref) => HiveScriptRepository(ref.watch(hiveServiceProvider)),
);

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => HiveProjectRepository(ref.watch(hiveServiceProvider)),
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

final recentScriptsProvider = StreamProvider<List<Script>>(
  (ref) => ref.watch(scriptRepositoryProvider).watchRecent(),
);
