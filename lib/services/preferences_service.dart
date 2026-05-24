import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for app-level flags. Initialized once
/// in main() so callers (incl. the GoRouter redirect, which runs outside the
/// ProviderScope) can read flags synchronously.
class PreferencesService {
  PreferencesService._(this._prefs);

  static PreferencesService? _instance;

  /// Available only after [init] has completed.
  static PreferencesService get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('PreferencesService.init() must be awaited first.');
    }
    return i;
  }

  final SharedPreferences _prefs;

  static const String _kOnboardingComplete = 'has_completed_onboarding';

  static Future<void> init() async {
    _instance ??= PreferencesService._(await SharedPreferences.getInstance());
  }

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_kOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboardingComplete, value);
}
