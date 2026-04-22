import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/adaptive_layout.dart';
import '../../shared/widgets/placeholder_screen.dart';

// Phase 2 feature screens
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/dashboard/screens/project_folder_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login', // Set initial route to login to demonstrate flow
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
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
          builder: (context, state) => ProjectFolderScreen(id: state.pathParameters['id']!),
        ),
        // Placeholders spanning future phases
        GoRoute(
          path: '/editor',
          builder: (context, state) => const PlaceholderScreen(title: 'AI Editor'),
        ),
        GoRoute(
          path: '/prompter',
          builder: (context, state) => const PlaceholderScreen(title: 'Prompter'),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
        ),
      ],
    ),
  ],
);
