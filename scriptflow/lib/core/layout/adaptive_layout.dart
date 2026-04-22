import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_shell.dart';
import 'web_desktop_shell.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget child;

  const AdaptiveLayout({
    required this.child,
    super.key,
  });

  /// Check if the platform is web OR screen width is >= 900
  static bool isDesktop(BuildContext context) {
    if (kIsWeb) return true;
    return MediaQuery.of(context).size.width >= 900;
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return WebDesktopShell(child: child);
    }
    return MobileShell(child: child);
  }
}
