import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/project.dart';
import '../../../data/models/script.dart';
import '../../../shared/widgets/script_card.dart';
import '../providers/dashboard_providers.dart';

class ProjectFolderScreen extends ConsumerWidget {
  final String id;

  const ProjectFolderScreen({required this.id, super.key});

  Future<void> _newScriptInFolder(BuildContext context, WidgetRef ref) async {
    final uuid = await ref
        .read(dashboardActionsProvider)
        .createScript(projectId: id, title: 'Untitled Script');
    if (context.mounted) context.push('/editor/$uuid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectByIdProvider(id)).valueOrNull;
    final scripts = ref.watch(scriptsByProjectProvider(id)).valueOrNull ??
        const <Script>[];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Project Folder',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        onPressed: () => _newScriptInFolder(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _Header(project: project),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search within this folder...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: scripts.isEmpty
                  ? const Center(
                      child: Text(
                        'No scripts in this folder yet.\nTap + to create one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: scripts.length,
                      itemBuilder: (context, index) {
                        final s = scripts[index];
                        return ScriptCard(
                          title: s.title,
                          previewContent:
                              s.content.isEmpty ? 'Empty script' : s.content,
                          status: s.status,
                          timestamp:
                              DateFormat.yMMMd().format(s.updatedAt),
                          onTap: () => context.push('/editor/${s.uuid}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.project});
  final Project? project;

  @override
  Widget build(BuildContext context) {
    final title = project?.title ?? 'Loading…';
    final desc = project?.description ?? project?.type.label ?? '';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              const Icon(Icons.folder, color: AppColors.accentBlue, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WORKSPACE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
