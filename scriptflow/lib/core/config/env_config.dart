import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed accessors over the `.env` file. Loaded once in `main()` via
/// `dotenv.load()` before `runApp`.
///
/// SECURITY NOTE: A key bundled into a client app is *not* secret — it ships
/// inside the build and can be extracted. For production, either (a) restrict
/// the key (API restrictions + app attestation) or (b) proxy Gemini calls
/// through a tiny serverless function.
abstract final class EnvConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static String get geminiModel =>
      dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.0-flash';

  static bool get isConfigured => geminiApiKey.isNotEmpty;
}
