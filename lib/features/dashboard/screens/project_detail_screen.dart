import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/script.dart';
import '../../../shared/widgets/script_card.dart';
import '../providers/dashboard_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({required this.projectId, super.key});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));
    final scriptsAsync = ref.watch(scriptsByProjectProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: projectAsync.when(
          data: (p) => Text(p?.title ?? 'Folder Not Found'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Script in Folder',
            onPressed: () async {
              final uuid = await ref
                  .read(dashboardActionsProvider)
                  .createScript(projectId: projectId);
              if (context.mounted) context.push('/editor/$uuid');
            },
          ),
        ],
      ),
      body: scriptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (scripts) {
          if (scripts.isEmpty) {
            return const Center(
              child: Text(
                'No scripts in this folder yet.\nTap + to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scripts.length,
            itemBuilder: (context, index) {
              final s = scripts[index];
              return ScriptCard(
                title: s.title,
                previewContent: s.content.isEmpty ? 'Empty script' : s.content,
                status: s.status,
                timestamp: 'Edited ${DateFormat.MMMd().format(s.updatedAt)}',
                onTap: () => context.push('/editor/${s.uuid}'),
              );
            },
          );
        },
      ),
    );
  }
}
