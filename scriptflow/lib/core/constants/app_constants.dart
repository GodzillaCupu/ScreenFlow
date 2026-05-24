/// App-wide constant values that are not theming or environment related.
abstract final class AppConstants {
  static const String appName = 'ScriptFlow';
  static const String tagline = 'The Focused Muse';

  // Editor auto-save debounce — persist this long after the last keystroke.
  static const Duration autoSaveDebounce = Duration(milliseconds: 800);

  // Teleprompter defaults (overridable per-script and at runtime).
  static const double teleprompterMinSpeed = 10; // px / second
  static const double teleprompterMaxSpeed = 220;
  static const double teleprompterDefaultSpeed = 60;

  static const double teleprompterMinFont = 24;
  static const double teleprompterMaxFont = 96;
  static const double teleprompterDefaultFont = 48;

  // Folder names created under the app documents directory.
  static const String recordingsDir = 'recordings';
  static const String exportsDir = 'exports';
}
