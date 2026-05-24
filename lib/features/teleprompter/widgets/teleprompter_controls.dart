import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/teleprompter_controller.dart';

/// Bottom control sheet: play/pause, restart, speed & font sliders, and the
/// mirror / focus-mode toggles. Mirrors the Figma's right-hand control panel,
/// re-laid-out for a phone.
class TeleprompterControls extends ConsumerWidget {
  const TeleprompterControls({
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onRestart,
    this.showRecord = false,
    this.isRecording = false,
    this.onToggleRecord,
    super.key,
  });

  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onRestart;

  /// Audio capture is device-microphone only (Android). Hidden elsewhere.
  final bool showRecord;
  final bool isRecording;
  final VoidCallback? onToggleRecord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tele = ref.watch(teleprompterControllerProvider);
    final notifier = ref.read(teleprompterControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgSidebar,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton.filled(
                onPressed: onTogglePlay,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.aiBlue,
                  fixedSize: const Size(56, 56),
                ),
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 30),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onRestart,
                icon: const Icon(Icons.replay,
                    color: AppColors.textSecondary),
                tooltip: 'Restart',
              ),
              if (showRecord) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onToggleRecord,
                  icon: Icon(
                    isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
                    color: AppColors.recordGreen,
                  ),
                  tooltip: isRecording ? 'Stop recording' : 'Record audio',
                ),
                if (isRecording) const _RecordingIndicator(),
              ],
              const Spacer(),
              Text(
                isPlaying ? 'PLAYING' : 'PAUSED',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LabeledSlider(
            label: 'Scroll Speed',
            value: tele.speed,
            min: AppConstants.teleprompterMinSpeed,
            max: AppConstants.teleprompterMaxSpeed,
            display: tele.speed.round().toString(),
            onChanged: notifier.setSpeed,
          ),
          _LabeledSlider(
            label: 'Font Size',
            value: tele.fontSize,
            min: AppConstants.teleprompterMinFont,
            max: AppConstants.teleprompterMaxFont,
            display: '${tele.fontSize.round()}px',
            onChanged: notifier.setFontSize,
          ),
          Row(
            children: [
              Expanded(
                child: _Toggle(
                  label: 'Mirror Text',
                  value: tele.mirror,
                  onChanged: (_) => notifier.toggleMirror(),
                ),
              ),
              Expanded(
                child: _Toggle(
                  label: 'Focus Mode',
                  value: tele.focusMode,
                  onChanged: (_) => notifier.toggleFocusMode(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small pulsing green dot + "REC" shown while audio capture is running.
class _RecordingIndicator extends StatefulWidget {
  const _RecordingIndicator();

  @override
  State<_RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<_RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_controller),
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.recordGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'REC',
            style: TextStyle(
              color: AppColors.recordGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
            Text(display,
                style: const TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.aiBlue,
          inactiveColor: AppColors.border,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Switch(
          value: value,
          activeColor: AppColors.aiBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
