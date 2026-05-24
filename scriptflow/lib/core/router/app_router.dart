import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/adaptive_layout.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/dashboard/screens/project_folder_screen.dart';
import '../../features/editor/editor_screen.dart';
import '../../features/scripts/script_list_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/teleprompter/teleprompter_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Full-screen experiences rendered above the shell (their own Scaffold).
    GoRoute(
      path: '/editor/:uuid',
      builder: (context, state) =>
          EditorScreen(scriptUuid: state.pathParameters['uuid']!),
    ),
    GoRoute(
      path: '/prompter/:uuid',
      builder: (context, state) =>
          TeleprompterScreen(scriptUuid: state.pathParameters['uuid']!),
    ),

    // Tabbed sections wrapped in the adaptive (sidebar / bottom-nav) shell.
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AdaptiveLayout(child: child),
      routes: [
        GoRoute(
          path: '/projects',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/projects/:id',
          builder: (context, state) =>
              ProjectFolderScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/editor',
          builder: (context, state) =>
              const ScriptListScreen(mode: ScriptListMode.edit),
        ),
        GoRoute(
          path: '/prompter',
          builder: (context, state) =>
              const ScriptListScreen(mode: ScriptListMode.prompt),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
