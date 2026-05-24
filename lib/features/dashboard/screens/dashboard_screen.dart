import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/layout/adaptive_layout.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/project.dart';
import '../../../data/models/script.dart';
import '../../../shared/widgets/folder_card.dart';
import '../../../shared/widgets/script_card.dart';
import '../providers/dashboard_providers.dart';
import '../providers/search_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _newScript(BuildContext context, WidgetRef ref) async {
    final uuid = await ref.read(dashboardActionsProvider).createScript();
    if (context.mounted) context.push('/editor/$uuid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDesktop = AdaptiveLayout.isDesktop(context);
    final projects = ref.watch(projectsProvider).valueOrNull ?? const [];
    final scripts = ref.watch(recentScriptsProvider).valueOrNull ?? const [];
    final filtered = ref.watch(filteredRecentScriptsProvider);
    final counts = ref.watch(projectScriptCountsProvider).valueOrNull ??
        const <String, int>{};

    final headerNode = _buildGreetingHeader(context, ref, scripts.length);
    final scriptsNode = _buildRecentScriptsList(context, ref, filtered);
    final foldersNode = _buildFoldersSection(context, projects, counts, ref);

    if (isDesktop) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side: Header and Folders (Channels) grid
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    headerNode,
                    const SizedBox(height: 48),
                    Expanded(child: foldersNode),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              // Right Side: Recent Scripts
              Expanded(
                flex: 4, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12), // Visual alignment
                    Expanded(child: scriptsNode),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildMobileAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              headerNode,
              const SizedBox(height: 24),
              foldersNode,
              const SizedBox(height: 24),
              scriptsNode,
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircleAvatar(
          backgroundColor: AppColors.accentBlue.withValues(alpha: 0.2),
          child:
              const Icon(Icons.person, color: AppColors.accentBlue, size: 20),
        ),
      ),
      title: const Text(
        'ScriptFlow',
        style: TextStyle(
            color: AppColors.accentBlue, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none,
              color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildGreetingHeader(
    BuildContext context,
    WidgetRef ref,
    int activeCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, Muse.',
          style:
              Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          activeCount == 0
              ? 'No scripts yet — start your first one.'
              : 'You have $activeCount script${activeCount == 1 ? '' : 's'} in your workspace.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _newScript(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New Script',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/prompter'),
              icon: const Icon(Icons.mic, color: Colors.white),
              label: const Text('Quick Capture',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgElevated,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentScriptsList(BuildContext context, WidgetRef ref, List<Script> scripts) {
    final bool isDesktop = AdaptiveLayout.isDesktop(context);

    Widget tile(Script s) => ScriptCard(
          title: s.title,
          previewContent: s.content.isEmpty ? 'Empty script' : s.content,
          status: s.status,
          timestamp: 'Edited ${DateFormat.MMMd().format(s.updatedAt)}',
          onTap: () => context.push('/editor/${s.uuid}'),
          onAction: (action) => _handleScriptAction(context, ref, s, action),
        );

    final query = ref.watch(searchQueryProvider);
    final Widget body;
    if (scripts.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
            query.isEmpty
                ? 'Your scripts will appear here.'
                : 'No scripts match "$query".',
            style: const TextStyle(color: AppColors.textMuted)),
      );
    } else {
      // Desktop fills remaining height (scrolls internally); mobile lives
      // inside a page-level SingleChildScrollView, so it must shrink-wrap and
      // NOT use Expanded (which is illegal under unbounded height).
      final list = ListView.builder(
        shrinkWrap: !isDesktop,
        physics:
            isDesktop ? null : const NeverScrollableScrollPhysics(),
        itemCount: scripts.length,
        itemBuilder: (context, index) => tile(scripts[index]),
      );
      body = isDesktop ? Expanded(child: list) : list;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Scripts', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {},
              child: const Text('View All',
                  style: TextStyle(color: AppColors.accentBlue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) =>
              ref.read(searchQueryProvider.notifier).state = value,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search scripts...',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: AppColors.bgElevated,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        body,
      ],
    );
  }

  Widget _buildFoldersSection(
    BuildContext context,
    List<Project> projects,
    Map<String, int> counts,
    WidgetRef ref,
  ) {
    final bool isDesktop = AdaptiveLayout.isDesktop(context);

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Channels', style: Theme.of(context).textTheme.titleLarge),
        TextButton(
          onPressed: () => _showCreateProjectDialog(context, ref),
          child: const Text('Manage',
              style: TextStyle(color: AppColors.accentBlue)),
        ),
      ],
    );

    if (projects.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 12),
          const Text('No folders yet.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      );
    }

    FolderCard cardFor(Project p) {
      final (icon, color) = _folderVisual(p.type);
      return FolderCard(
        title: p.title,
        description: p.description ?? p.type.label,
        scriptCount: counts[p.uuid] ?? 0,
        icon: icon,
        iconColor: color,
        onTap: () => context.go('/projects/${p.uuid}'),
      );
    }

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: projects.length,
              itemBuilder: (context, index) => cardFor(projects[index]),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            separatorBuilder: (c, i) => const SizedBox(width: 12),
            itemBuilder: (c, index) => SizedBox(
              width: 160,
              child: cardFor(projects[index]),
            ),
          ),
        ),
      ],
    );
  }

  (IconData, Color) _folderVisual(ProjectType type) => switch (type) {
        ProjectType.youtubeLongform => (Icons.play_arrow, AppColors.accentRed),
        ProjectType.shorts => (Icons.music_note, AppColors.accentGreen),
        ProjectType.podcast => (Icons.mic, AppColors.accentBlue),
        ProjectType.videoEssay => (Icons.movie_outlined, AppColors.accentBlue),
        ProjectType.other => (Icons.folder, AppColors.textSecondary),
      };

  Future<void> _showCreateProjectDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    ProjectType selectedType = ProjectType.youtubeLongform;
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.bgSurface,
              title: const Text('New Channel', style: TextStyle(color: AppColors.textPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Channel Name',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ProjectType>(
                    value: selectedType,
                    dropdownColor: AppColors.bgElevated,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Content Type',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                    ),
                    items: ProjectType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      ref.read(dashboardActionsProvider).createProject(
                            title: titleController.text.trim(),
                            type: selectedType,
                          );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleScriptAction(
    BuildContext context,
    WidgetRef ref,
    Script script,
    String action,
  ) async {
    final actions = ref.read(dashboardActionsProvider);
    switch (action) {
      case 'rename':
        await _showRenameDialog(context, ref, script);
      case 'status':
        await _showStatusDialog(context, ref, script);
      case 'archive':
        await actions.setArchived(script.uuid, true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Script moved to Archive.'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => actions.setArchived(script.uuid, false),
              ),
            ),
          );
        }
      case 'delete':
        await _showDeleteDialog(context, ref, script);
    }
  }

  Future<void> _showRenameDialog(
      BuildContext context, WidgetRef ref, Script script) async {
    final controller = TextEditingController(text: script.title);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Rename Script',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'New title',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.accentBlue)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(dashboardActionsProvider)
                    .renameScript(script, controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showStatusDialog(
      BuildContext context, WidgetRef ref, Script script) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Change Status',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ScriptStatus.values
              .map((s) => RadioListTile<ScriptStatus>(
                    value: s,
                    groupValue: script.status,
                    title: Text(s.label,
                        style: const TextStyle(color: AppColors.textPrimary)),
                    activeColor: AppColors.accentBlue,
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(dashboardActionsProvider)
                            .updateScriptStatus(script, val);
                        Navigator.pop(ctx);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, Script script) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Delete Script',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Permanently delete "${script.title}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(dashboardActionsProvider).deleteScript(script.uuid);
    }
  }
}



