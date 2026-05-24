import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';

/// Playback + appearance state for the teleprompter. The *scroll animation*
/// itself lives in the screen (it needs the widget's ScrollController +
/// Ticker); this controller just holds the tunable parameters the controls
/// panel binds to.
class TeleprompterState {
  const TeleprompterState({
    this.isPlaying = false,
    this.speed = AppConstants.teleprompterDefaultSpeed,
    this.fontSize = AppConstants.teleprompterDefaultFont,
    this.mirror = false,
    this.focusMode = true,
  });

  /// Scroll velocity in logical pixels per second.
  final double speed;
  final double fontSize;
  final bool isPlaying;
  final bool mirror;
  final bool focusMode;

  TeleprompterState copyWith({
    bool? isPlaying,
    double? speed,
    double? fontSize,
    bool? mirror,
    bool? focusMode,
  }) {
    return TeleprompterState(
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      fontSize: fontSize ?? this.fontSize,
      mirror: mirror ?? this.mirror,
      focusMode: focusMode ?? this.focusMode,
    );
  }
}

class TeleprompterController extends Notifier<TeleprompterState> {
  @override
  TeleprompterState build() => const TeleprompterState();

  void play() => state = state.copyWith(isPlaying: true);
  void pause() => state = state.copyWith(isPlaying: false);
  void togglePlay() => state = state.copyWith(isPlaying: !state.isPlaying);

  void setSpeed(double v) => state = state.copyWith(
        speed: v.clamp(
          AppConstants.teleprompterMinSpeed,
          AppConstants.teleprompterMaxSpeed,
        ),
      );

  void setFontSize(double v) => state = state.copyWith(
        fontSize: v.clamp(
          AppConstants.teleprompterMinFont,
          AppConstants.teleprompterMaxFont,
        ),
      );

  void toggleMirror() => state = state.copyWith(mirror: !state.mirror);
  void toggleFocusMode() => state = state.copyWith(focusMode: !state.focusMode);
}

final teleprompterControllerProvider =
    NotifierProvider<TeleprompterController, TeleprompterState>(
  TeleprompterController.new,
);
