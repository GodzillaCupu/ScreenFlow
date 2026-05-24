import 'package:flutter/material.dart';
import 'sidebar_navigation.dart';

class WebDesktopShell extends StatelessWidget {
  final Widget child;

  const WebDesktopShell({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarNavigation(),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
