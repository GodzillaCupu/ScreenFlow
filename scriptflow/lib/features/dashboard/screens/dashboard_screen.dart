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
    final counts = ref.watch(projectScriptCountsProvider).valueOrNull ??
        const <String, int>{};

    final headerNode = _buildGreetingHeader(context, ref, scripts.length);
    final scriptsNode = _buildRecentScriptsList(context, scripts);
    final foldersNode = _buildFoldersSection(context, projects, counts);

    if (isDesktop) {
      return Scaffold(
        body: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    headerNode,
                    const SizedBox(height: 32),
                    Expanded(child: scriptsNode),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(flex: 4, child: foldersNode),
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

  Widget _buildRecentScriptsList(BuildContext context, List<Script> scripts) {
    final bool isDesktop = AdaptiveLayout.isDesktop(context);

    Widget tile(Script s) => ScriptCard(
          title: s.title,
          previewContent: s.content.isEmpty ? 'Empty script' : s.content,
          status: s.status,
          timestamp: 'Edited ${DateFormat.MMMd().format(s.updatedAt)}',
          onTap: () => context.push('/editor/${s.uuid}'),
        );

    final Widget body;
    if (scripts.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('Your scripts will appear here.',
            style: TextStyle(color: AppColors.textMuted)),
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
        Text('Recent Scripts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        body,
      ],
    );
  }

  Widget _buildFoldersSection(
    BuildContext context,
    List<Project> projects,
    Map<String, int> counts,
  ) {
    final bool isDesktop = AdaptiveLayout.isDesktop(context);

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Folders', style: Theme.of(context).textTheme.titleLarge),
        TextButton(
          onPressed: () {},
          child: const Text('View All',
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
            child: ListView.separated(
              itemCount: projects.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (c, index) => AspectRatio(
                aspectRatio: 2.0,
                child: cardFor(projects[index]),
              ),
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
}
