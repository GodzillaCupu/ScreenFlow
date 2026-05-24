import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers.dart';
import '../../../data/models/script.dart';

/// Immutable view-state for one open script in the editor.
class EditorState {
  const EditorState({
    this.script,
    this.isLoading = true,
    this.isSaving = false,
    this.lastSavedAt,
  });

  final Script? script;
  final bool isLoading;
  final bool isSaving;
  final DateTime? lastSavedAt;

  int get wordCount => script?.wordCount ?? 0;

  EditorState copyWith({
    Script? script,
    bool? isLoading,
    bool? isSaving,
    DateTime? lastSavedAt,
  }) {
    return EditorState(
      script: script ?? this.script,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }
}

/// Loads a script by uuid and debounces auto-saves to the local DB. This is
/// the heart of the "auto-save to local database" requirement.
///
/// Usage:
///   final state = ref.watch(editorControllerProvider(uuid));
///   ref.read(editorControllerProvider(uuid).notifier).onContentChanged(text);
class EditorController extends FamilyNotifier<EditorState, String> {
  Timer? _debounce;

  @override
  EditorState build(String scriptUuid) {
    ref.onDispose(() => _debounce?.cancel());
    _load(scriptUuid);
    return const EditorState();
  }

  Future<void> _load(String uuid) async {
    final repo = ref.read(scriptRepositoryProvider);
    final script = await repo.getByUuid(uuid);
    state = state.copyWith(
      script: script,
      isLoading: false,
      lastSavedAt: script?.updatedAt,
    );
  }

  /// Called on every keystroke. Resets a debounce timer so we persist only
  /// once the user pauses typing — avoids hammering the DB.
  void onContentChanged(String content) {
    final current = state.script;
    if (current == null) return;
    current.content = content;
    _debounce?.cancel();
    _debounce = Timer(AppConstants.autoSaveDebounce, _persist);
  }

  /// Force an immediate save (e.g. on screen pop / before export).
  Future<void> flush() async {
    _debounce?.cancel();
    await _persist();
  }

  Future<void> _persist() async {
    final script = state.script;
    if (script == null) return;
    state = state.copyWith(isSaving: true);
    await ref.read(scriptRepositoryProvider).save(script);
    state = state.copyWith(
      isSaving: false,
      lastSavedAt: DateTime.now(),
      script: script,
    );
  }

  void updateStatus(ScriptStatus status) {
    final script = state.script;
    if (script == null) return;
    script.status = status;
    _persist();
  }

  void updateTitle(String title) {
    final script = state.script;
    if (script == null) return;
    script.title = title;
    onContentChanged(script.content); // reuse the debounce
  }
}

final editorControllerProvider =
    NotifierProvider.family<EditorController, EditorState, String>(
  EditorController.new,
);
