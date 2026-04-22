import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note: flutter_web_plugins is handled dynamically on web, but for clean url strategy:
// Use conditional import or flutter_web_plugins/url_strategy.dart if available.
// For now, standard hash URL is fine until web plugin is explicitly verified.

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Stub for now: requires google-services.json and flutterfire config)
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
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
