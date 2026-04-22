import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/folder_card.dart';
import '../../../shared/widgets/script_card.dart';
import '../../../shared/widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = AdaptiveLayout.isDesktop(context);

    // Common widgets for both layouts
    final appbarNode = _buildMobileAppBar();
    final headerNode = _buildGreetingHeader(context);
    final scriptsNode = _buildRecentScriptsList(context);
    final foldersNode = _buildFoldersSection(context);

    if (isDesktop) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column (60%)
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
              // Right column (40%)
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Expanded(child: foldersNode),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    // Mobile Layout
    return Scaffold(
      appBar: appbarNode,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              headerNode,
              const SizedBox(height: 24),
              // Horizontal folders
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
          child: const Icon(Icons.person, color: AppColors.accentBlue, size: 20),
        ),
      ),
      title: const Text(
        'ScriptFlow',
        style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildGreetingHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, Muse.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'You have 3 active scripts in progress.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('New Script', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mic, color: Colors.white),
              label: const Text('Quick Capture', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgElevated,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildRecentScriptsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Scripts',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 4,
            itemBuilder: (context, index) {
              return ScriptCard(
                title: 'Tech Review Script $index',
                previewContent: 'INT. STUDIO - DAY\nHey guys, welcome back to the channel. Today we are reviewing...',
                status: index % 2 == 0 ? ScriptStatus.draft : ScriptStatus.ready,
                timestamp: 'Edited 2h ago',
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoldersSection(BuildContext context) {
    final bool isDesktop = AdaptiveLayout.isDesktop(context);
    
    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Folders',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(
          onPressed: () {},
          child: const Text('View All', style: TextStyle(color: AppColors.accentBlue)),
        ),
      ],
    );

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: 3,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (c, index) {
                return AspectRatio(
                  aspectRatio: 2.0, // Desktop cards might be wider
                  child: FolderCard(
                    title: 'YouTube',
                    description: 'Main channel content',
                    scriptCount: 12,
                    icon: Icons.play_arrow,
                    iconColor: AppColors.accentRed,
                    onTap: () => context.go('/projects/folder_1'),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } 
    
    // Mobile: Horizontal scrolling row
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (c, i) => const SizedBox(width: 12),
            itemBuilder: (c, index) {
              return SizedBox(
                width: 160, // Fixed width for horizontal scroll
                child: FolderCard(
                  title: 'TikTok',
                  description: 'Short form content',
                  scriptCount: 4,
                  icon: Icons.music_note,
                  iconColor: AppColors.accentGreen,
                  onTap: () => context.go('/projects/folder_1'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
