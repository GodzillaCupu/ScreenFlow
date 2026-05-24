import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MobileShell extends StatelessWidget {
  final Widget child;

  const MobileShell({
    required this.child,
    super.key,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/projects')) return 0;
    if (location.startsWith('/editor')) return 1;
    if (location.startsWith('/prompter')) return 2;
    if (location.startsWith('/archive')) return 3;
    if (location.startsWith('/settings')) return 4;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.bgPrimary,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.accentBlue,
          unselectedItemColor: AppColors.textSecondary,
          currentIndex: _calculateSelectedIndex(context),
          onTap: (int idx) => _onItemTapped(idx, context),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note_outlined),
              activeIcon: Icon(Icons.edit_note),
              label: 'AI Editor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline),
              activeIcon: Icon(Icons.play_circle_filled),
              label: 'Prompter',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Vault',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
