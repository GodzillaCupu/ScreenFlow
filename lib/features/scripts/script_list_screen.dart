import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/script_card.dart';
import '../dashboard/providers/dashboard_providers.dart';

enum ScriptListMode { edit, prompt }

/// Picker reached from the "AI Editor" / "Prompter" nav tabs. Lists recent
/// scripts; tapping routes into the editor or teleprompter for that script.
class ScriptListScreen extends ConsumerWidget {
  const ScriptListScreen({required this.mode, super.key});
  final ScriptListMode mode;

  bool get _isEdit => mode == ScriptListMode.edit;

  Future<void> _newScript(BuildContext context, WidgetRef ref) async {
    final uuid = await ref.read(dashboardActionsProvider).createScript();
    if (context.mounted) context.push('/editor/$uuid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripts = ref.watch(recentScriptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'AI Editor' : 'Teleprompter'),
      ),
      floatingActionButton: _isEdit
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.aiBlue,
              onPressed: () => _newScript(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New Script'),
            )
          : null,
      body: scripts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(
                _isEdit
                    ? 'No scripts yet — tap "New Script" to begin.'
                    : 'Write a script first, then run it here.',
                style: const TextStyle(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return ScriptCard(
                title: s.title,
                previewContent:
                    s.content.isEmpty ? 'Empty script' : s.content,
                status: s.status,
                timestamp: 'Edited ${DateFormat.MMMd().format(s.updatedAt)}',
                onTap: () => context.push(
                  _isEdit ? '/editor/${s.uuid}' : '/prompter/${s.uuid}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
