import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/script.dart';
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
  // Called once per frame while playing. `elapsed` is the total time the
  // Ticker has been active; we take the delta since the previous frame and
  // advance the scroll offset by (speed × dt). This keeps a constant on-screen
  // reading speed regardless of whether the device renders at 60 or 120 fps.
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
      // Ticker.elapsed restarts at zero on start(), so reset the baseline to
      // avoid a huge first-frame delta that would jump the scroll position.
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

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tele = ref.watch(teleprompterControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                  TeleprompterControls(
                    isPlaying: tele.isPlaying,
                    onTogglePlay: _toggle,
                    onRestart: _restart,
                  ),
                ],
              ),
      ),
    );
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
