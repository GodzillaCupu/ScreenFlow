import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env_config.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/layout/adaptive_layout.dart';

/// The "Ask Muse to brainstorm…" panel. Streams Gemini output live and
/// lets the writer insert the result into the script.
class MusePanel extends ConsumerStatefulWidget {
  const MusePanel({
    required this.scriptContext,
    required this.onInsert,
    super.key,
  });

  final String scriptContext;
  final ValueChanged<String> onInsert;

  @override
  ConsumerState<MusePanel> createState() => _MusePanelState();
}

class _MusePanelState extends ConsumerState<MusePanel> {
  final TextEditingController _prompt = TextEditingController();
  String _output = '';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _run(Stream<String> stream) async {
    setState(() {
      _busy = true;
      _output = '';
      _error = null;
    });
    try {
      await for (final token in stream) {
        if (!mounted) return;
        setState(() => _output += token);
      }
    } on Exception catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _generate() {
    final gemini = ref.read(geminiServiceProvider);
    _run(gemini.generateStream(
      _prompt.text.trim().isEmpty
          ? 'Brainstorm 3 fresh angles for this script.'
          : _prompt.text.trim(),
      scriptContext: widget.scriptContext,
    ));
  }

  Future<void> _fixGrammar() async {
    final gemini = ref.read(geminiServiceProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final fixed = await gemini.fixGrammar(widget.scriptContext);
      if (mounted) setState(() => _output = fixed);
    } on Exception catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AdaptiveLayout.isDesktop(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (!EnvConfig.isConfigured) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.key_off, color: AppColors.warning, size: 32),
            SizedBox(height: 12),
            Text(
              'No Gemini API key configured.\n'
              'Add GEMINI_API_KEY to your .env to enable The Muse.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      color: isDesktop ? AppColors.bgSidebar : Colors.transparent,
      padding: EdgeInsets.fromLTRB(20, isDesktop ? 24 : 16, 20, isDesktop ? 24 : bottomInset + 20),
      child: Column(
        mainAxisSize: isDesktop ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: AppColors.aiBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'The Muse',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isDesktop) const Spacer(), // Push content to bottom on desktop
          if (_output.isNotEmpty || _busy)
            Container(
              constraints: BoxConstraints(maxHeight: isDesktop ? 400 : 240),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Text(
                  _output.isEmpty ? 'Thinking…' : _output,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!,
                  style: const TextStyle(color: AppColors.danger)),
            ),
          TextField(
            controller: _prompt,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ask Muse to brainstorm, rewrite, expand…',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _generate,
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text('Generate'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _fixGrammar,
                  icon: const Icon(Icons.spellcheck, size: 18),
                  label: const Text('Fix Grammar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          if (_output.isNotEmpty && !_busy) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  widget.onInsert(_output);
                  if (!isDesktop) {
                    Navigator.of(context).maybePop();
                  }
                },
                icon: const Icon(Icons.add, color: AppColors.recordGreen),
                label: const Text(
                  'Insert into script',
                  style: TextStyle(color: AppColors.recordGreen),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

