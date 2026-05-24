import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/script.dart';
import 'providers/editor_controller.dart';
import 'widgets/muse_panel.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({required this.scriptUuid, super.key});
  final String scriptUuid;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final controller =
        ref.read(editorControllerProvider(widget.scriptUuid).notifier);
    await controller.flush();
    final script = ref.read(editorControllerProvider(widget.scriptUuid)).script;
    if (script == null) return;
    await ref.read(exportServiceProvider).exportAndShare(
          title: script.title,
          content: script.content,
        );
  }

  void _openMuse(Script script) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MusePanel(
        scriptContext: script.content,
        onInsert: (text) {
          final insertion = _textController.text.isEmpty ? text : '\n\n$text';
          _textController.text = _textController.text + insertion;
          ref
              .read(editorControllerProvider(widget.scriptUuid).notifier)
              .onContentChanged(_textController.text);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = editorControllerProvider(widget.scriptUuid);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    // Seed the text field once, after the script loads from the DB.
    if (!_initialized && state.script != null) {
      _textController.text = state.script!.content;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            await controller.flush(); // never lose the last edits
            if (context.mounted) context.pop();
          },
        ),
        title: Text(state.script?.title ?? 'Editor'),
        actions: [
          IconButton(
            tooltip: 'Export .txt',
            icon: const Icon(Icons.ios_share),
            onPressed: state.script == null ? null : _export,
          ),
          IconButton(
            tooltip: 'Teleprompter',
            icon: const Icon(Icons.slideshow, color: AppColors.recordGreen),
            onPressed: state.script == null
                ? null
                : () => context.push('/prompter/${widget.scriptUuid}'),
          ),
        ],
      ),
      floatingActionButton: state.script == null
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.aiBlue,
              onPressed: () => _openMuse(state.script!),
              child: const Icon(Icons.auto_awesome),
            ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.script == null
              ? const Center(child: Text('Script not found.'))
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _textController,
                          onChanged: controller.onContentChanged,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.6,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            hintText: 'Start writing, or tap the spark to '
                                'summon The Muse…',
                          ),
                        ),
                      ),
                    ),
                    _StatusBar(state: state),
                  ],
                ),
    );
  }
}

/// Footer mirroring the Figma: word count + "Saved …".
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.state});
  final EditorState state;

  String get _savedLabel {
    if (state.isSaving) return 'Saving…';
    final ts = state.lastSavedAt;
    if (ts == null) return 'Not saved yet';
    return 'Saved ${DateFormat.jm().format(ts)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgSidebar,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            '${state.wordCount} words',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const Spacer(),
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          Text(
            _savedLabel,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
