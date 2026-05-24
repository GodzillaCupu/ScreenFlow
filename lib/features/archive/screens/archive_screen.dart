import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/script.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../dashboard/providers/dashboard_providers.dart';

/// "The Vault" — scripts the user has archived. Restore puts them back into
/// the active workspace; delete removes them permanently.
class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archived = ref.watch(archivedScriptsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('The Vault',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: archived.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Could not load the vault: $e',
              style: const TextStyle(color: AppColors.textMuted)),
        ),
        data: (scripts) {
          if (scripts.isEmpty) {
            return const _EmptyVault();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: scripts.length,
            itemBuilder: (context, index) => _ArchivedTile(
              script: scripts[index],
              onRestore: () => _restore(context, ref, scripts[index]),
              onDelete: () => _confirmDelete(context, ref, scripts[index]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _restore(
      BuildContext context, WidgetRef ref, Script script) async {
    await ref.read(dashboardActionsProvider).setArchived(script.uuid, false);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Script restored to your workspace.')),
      );
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Script script) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Delete Forever',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Permanently delete "${script.title}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(dashboardActionsProvider).deleteScript(script.uuid);
    }
  }
}

class _EmptyVault extends StatelessWidget {
  const _EmptyVault();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('The vault is empty.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
          SizedBox(height: 4),
          Text('Archived scripts will show up here.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ArchivedTile extends StatelessWidget {
  const _ArchivedTile({
    required this.script,
    required this.onRestore,
    required this.onDelete,
  });

  final Script script;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    script.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: script.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              script.content.isEmpty ? 'Empty script' : script.content,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Archived ${DateFormat.MMMd().format(script.updatedAt)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onRestore,
                      icon: const Icon(Icons.unarchive_outlined, size: 18),
                      label: const Text('Restore'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentBlue),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.danger),
                      tooltip: 'Delete forever',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
