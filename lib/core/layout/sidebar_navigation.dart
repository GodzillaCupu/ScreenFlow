import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_colors.dart';
import '../providers.dart';
import '../../data/models/script.dart';

class SidebarNavigation extends ConsumerWidget {
  const SidebarNavigation({super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/editor')) return 1;
    if (location.startsWith('/prompter')) return 2;
    if (location.startsWith('/archive')) return 3;
    if (location.startsWith('/settings')) return 4;
    // Default to Dashboard (Projects)
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/projects');
        break;
      case 1:
        context.go('/editor');
        break;
      case 2:
        context.go('/prompter');
        break;
      case 3:
        context.go('/archive');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  Future<void> _createNewScript(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(scriptRepositoryProvider);
    final uuid = const Uuid().v4();
    final script = Script()
      ..uuid = uuid
      ..title = 'Untitled Script'
      ..content = ''
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await repository.save(script);
    if (context.mounted) {
      // Navigate directly to the editor for the new script
      context.push('/editor/$uuid');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Container(
      width: 240,
      color: AppColors.bgSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Logo
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ScriptFlow',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'THE FOCUSED MUSE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          
          // New Script Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _createNewScript(context, ref),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('New Script', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _NavItem(
                  icon: Icons.folder_outlined,
                  activeIcon: Icons.folder,
                  label: 'Dashboard',
                  isSelected: selectedIndex == 0,
                  onTap: () => _onItemTapped(0, context),
                ),
                _NavItem(
                  icon: Icons.edit_note_outlined,
                  activeIcon: Icons.edit_note,
                  label: 'Editor',
                  isSelected: selectedIndex == 1,
                  onTap: () => _onItemTapped(1, context),
                ),
                _NavItem(
                  icon: Icons.slideshow_outlined,
                  activeIcon: Icons.slideshow,
                  label: 'Teleprompter',
                  isSelected: selectedIndex == 2,
                  onTap: () => _onItemTapped(2, context),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  label: 'Archive',
                  isSelected: selectedIndex == 3,
                  onTap: () => _onItemTapped(3, context),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Divider(color: AppColors.border),
                ),

                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  isSelected: selectedIndex == 4,
                  onTap: () => _onItemTapped(4, context),
                ),
              ],
            ),
          ),
          
          // User Avatar bottom area (Profile Block)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.accentBlue,
                  radius: 18,
                  child: Icon(Icons.person, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creator',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Pro Plan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? Colors.white : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.bgSidebar, // Using slightly lighter color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalTitleGap: 8,
        onTap: onTap,
      ),
    );
  }
}
