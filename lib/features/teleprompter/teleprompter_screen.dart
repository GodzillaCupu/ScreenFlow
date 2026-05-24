import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/script.dart';
import '../../core/layout/adaptive_layout.dart';
import '../../core/layout/web_desktop_shell.dart';
import 'providers/teleprompter_controller.dart';
import 'widgets/teleprompter_controls.dart';

/// Full-screen auto-scrolling teleprompter for a single script.
class TeleprompterScreen extends ConsumerStatefulWidget {
  const TeleprompterScreen({required this.scriptUuid, super.key});
  final String scriptUuid;

  @override
  ConsumerState<TeleprompterScreen> createState() => _TeleprompterScreenState();
}

class _TeleprompterScreenState extends ConsumerState<TeleprompterScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  /// Drives a callback every frame so scrolling is smooth and, crucially,
  /// frame-rate independent (we advance by elapsed time, not a fixed step).
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  Script? _script;
  bool _loading = true;
  bool _isRecording = false;

  /// Local mic capture is only wired for Android devices (not web/desktop).
  bool get _canRecord =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _loadScript();
  }

  Future<void> _loadScript() async {
    final script =
        await ref.read(scriptRepositoryProvider).getByUuid(widget.scriptUuid);
    if (!mounted) return;
    setState(() {
      _script = script;
      _loading = false;
    });
  }

  // ── Core auto-scroll implementation ───────────────────────────────────
  void _onTick(Duration elapsed) {
    final dtSeconds = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (!_scrollController.hasClients) return;

    final speed = ref.read(teleprompterControllerProvider).speed;
    final max = _scrollController.position.maxScrollExtent;
    final next = _scrollController.offset + speed * dtSeconds;

    if (next >= max) {
      _scrollController.jumpTo(max);
      _stop(); // reached the end — auto-pause
    } else {
      _scrollController.jumpTo(next);
    }
  }

  void _start() {
    if (!_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
    ref.read(teleprompterControllerProvider.notifier).play();
  }

  void _stop() {
    if (_ticker.isActive) _ticker.stop();
    ref.read(teleprompterControllerProvider.notifier).pause();
  }

  void _toggle() =>
      ref.read(teleprompterControllerProvider).isPlaying ? _stop() : _start();

  void _restart() {
    _stop();
    _scrollController.jumpTo(0);
    _lastTick = Duration.zero;
  }

  // ── Audio capture (Android only) ──────────────────────────────────────
  Future<void> _toggleRecording() async {
    final service = ref.read(audioRecorderServiceProvider);
    if (_isRecording) {
      final path = await service.stop();
      if (mounted) setState(() => _isRecording = false);
      if (path != null && _script != null) {
        // Persist the new take so it travels with the script offline.
        _script!.recordingPaths = [..._script!.recordingPaths, path];
        await ref.read(scriptRepositoryProvider).save(_script!);
      }
    } else {
      if (!await service.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied.')),
          );
        }
        return;
      }
      await service.start(widget.scriptUuid);
      if (mounted) setState(() => _isRecording = true);
    }
  }

  @override
  void dispose() {
    if (_isRecording) {
      // Fire-and-forget: finalize the file even if the user backs out.
      ref.read(audioRecorderServiceProvider).stop();
    }
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tele = ref.watch(teleprompterControllerProvider);
    final isDesktop = AdaptiveLayout.isDesktop(context);

    final Widget body = SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(
                        title: _script?.title ?? 'Untitled',
                        onClose: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _ScrollingText(
                              controller: _scrollController,
                              text: _script?.content ?? '',
                              fontSize: tele.fontSize,
                              mirror: tele.mirror,
                            ),
                            if (tele.focusMode) const _FocusOverlay(),
                          ],
                        ),
                      ),
                      if (!isDesktop)
                        TeleprompterControls(
                          isPlaying: tele.isPlaying,
                          onTogglePlay: _toggle,
                          onRestart: _restart,
                          showRecord: _canRecord,
                          isRecording: _isRecording,
                          onToggleRecord: _toggleRecording,
                        ),
                    ],
                  ),
                ),
                if (isDesktop) ...[
                  const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
                  SizedBox(
                    width: 320,
                    child: Container(
                      color: AppColors.bgSidebar,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Prompter Settings',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          TeleprompterControls(
                            isPlaying: tele.isPlaying,
                            onTogglePlay: _toggle,
                            onRestart: _restart,
                            showRecord: _canRecord,
                            isRecording: _isRecording,
                            onToggleRecord: _toggleRecording,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );

    final scaffold = Scaffold(
      backgroundColor: Colors.black,
      body: body,
    );

    if (isDesktop) {
      return WebDesktopShell(child: scaffold);
    }
    
    return scaffold;
  }
}

class _ScrollingText extends StatelessWidget {
  const _ScrollingText({
    required this.controller,
    required this.text,
    required this.fontSize,
    required this.mirror,
  });

  final ScrollController controller;
  final String text;
  final double fontSize;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(), // driven by the Ticker
      child: Padding(
        // Top/bottom padding lets the first/last line reach screen center.
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 240),
        child: Text(
          text.isEmpty ? 'This script is empty.' : text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: fontSize,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    // "Mirror Text" flips horizontally for use with a physical beam-splitter.
    return mirror ? Transform.flip(flipX: true, child: body) : body;
  }
}

/// Dims the top and bottom thirds, leaving a bright reading band in the
/// middle — the "Focus Mode" from the Figma.
class _FocusOverlay extends StatelessWidget {
  const _FocusOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.85),
            ],
            stops: const [0.0, 0.32, 0.68, 1.0],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onClose});
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

