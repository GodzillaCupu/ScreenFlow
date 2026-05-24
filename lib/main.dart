import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted flags (onboarding, etc.) before the router's first redirect.
  await PreferencesService.init();

  // Local-first: no Firebase. Load the Gemini key + config before runApp.
  // Wrapped so a missing .env during early dev doesn't hard-crash the app.
  try {
    await dotenv.load(fileName: '.env');
  } on Exception {
    debugPrint('.env not found — AI features disabled until configured.');
  }

  runApp(
    const ProviderScope(
      child: ScriptFlowApp(),
    ),
  );
}

class ScriptFlowApp extends ConsumerWidget {
  const ScriptFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ScriptFlow',
      theme: appTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
