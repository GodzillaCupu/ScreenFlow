import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/script.dart';
import '../../core/layout/adaptive_layout.dart';
import '../../core/layout/web_desktop_shell.dart';
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
        onInsert: _handleMuseInsert,
      ),
    );
  }

  void _handleMuseInsert(String text) {
    final insertion = _textController.text.isEmpty ? text : '\n\n$text';
    _textController.text = _textController.text + insertion;
    ref
        .read(editorControllerProvider(widget.scriptUuid).notifier)
        .onContentChanged(_textController.text);
  }

  Widget _buildEditorField(EditorState state, EditorController controller, bool isDesktop) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.script == null) {
      return const Center(child: Text('Script not found.'));
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20),
      child: TextField(
        controller: _textController,
        onChanged: controller.onContentChanged,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: isDesktop ? 18 : 17,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          filled: false,
          border: InputBorder.none,
          hintText: 'Start writing, or tap the spark to summon The Muse…',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = editorControllerProvider(widget.scriptUuid);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final isDesktop = AdaptiveLayout.isDesktop(context);

    // Seed the text field once, after the script loads from the DB.
    if (!_initialized && state.script != null) {
      _textController.text = state.script!.content;
      _initialized = true;
    }

    if (isDesktop) {
      return WebDesktopShell(
        child: Scaffold(
          backgroundColor: AppColors.bgSurface,
          body: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _DesktopToolbar(
                      state: state,
                      controller: controller,
                      onExport: _export,
                      onTeleprompter: () => context.push('/prompter/${widget.scriptUuid}'),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: _buildEditorField(state, controller, true),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
              SizedBox(
                width: 320,
                child: state.script == null
                    ? const SizedBox()
                    : MusePanel(
                        scriptContext: _textController.text, // Live context
                        onInsert: _handleMuseInsert,
                      ),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile Layout
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
      body: Column(
        children: [
          Expanded(child: _buildEditorField(state, controller, false)),
          _StatusBar(state: state),
        ],
      ),
    );
  }
}

class _DesktopToolbar extends StatefulWidget {
  const _DesktopToolbar({
    required this.state,
    required this.controller,
    required this.onExport,
    required this.onTeleprompter,
  });

  final EditorState state;
  final EditorController controller;
  final VoidCallback onExport;
  final VoidCallback onTeleprompter;

  @override
  State<_DesktopToolbar> createState() => _DesktopToolbarState();
}

class _DesktopToolbarState extends State<_DesktopToolbar> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.state.script?.title ?? 'Untitled Script',
    );
  }

  @override
  void didUpdateWidget(covariant _DesktopToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.script?.title != oldWidget.state.script?.title &&
        widget.state.script?.title != _titleController.text) {
      _titleController.text = widget.state.script?.title ?? 'Untitled Script';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String get _savedLabel {
    if (widget.state.isSaving) return 'Saving…';
    final ts = widget.state.lastSavedAt;
    if (ts == null) return 'Not saved yet';
    return 'Saved ${DateFormat.jm().format(ts)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              onChanged: widget.controller.updateTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Formatting tools mock
          IconButton(icon: const Icon(Icons.format_bold, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.format_italic, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.format_underlined, size: 20), onPressed: () {}),
          const SizedBox(width: 8),
          const SizedBox(height: 24, child: VerticalDivider(color: AppColors.border)),
          const SizedBox(width: 8),
          // Status indicators
          Text(
            '${widget.state.wordCount} words',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(width: 16),
          if (widget.state.isSaving)
            const SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(Icons.check_circle_outline, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            _savedLabel,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(width: 24),
          OutlinedButton.icon(
            onPressed: widget.state.script == null ? null : widget.onExport,
            icon: const Icon(Icons.ios_share, size: 16),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: widget.state.script == null ? null : widget.onTeleprompter,
            icon: const Icon(Icons.slideshow, size: 16),
            label: const Text('Prompter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.recordGreen,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
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

