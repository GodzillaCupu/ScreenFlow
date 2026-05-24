import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/script.dart';
import 'status_badge.dart';

class ScriptCard extends StatelessWidget {
  final String title;
  final String previewContent;
  final ScriptStatus status;
  final String timestamp;
  final VoidCallback onTap;
  final void Function(String action)? onAction;

  const ScriptCard({
    required this.title,
    required this.previewContent,
    required this.status,
    required this.timestamp,
    required this.onTap,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Title and More menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (onAction != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 20),
                      color: AppColors.bgElevated,
                      onSelected: onAction,
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'rename', child: Text('Rename', style: TextStyle(color: AppColors.textPrimary))),
                        PopupMenuItem(value: 'status', child: Text('Change Status', style: TextStyle(color: AppColors.textPrimary))),
                        PopupMenuItem(value: 'archive', child: Text('Archive', style: TextStyle(color: AppColors.textPrimary))),
                        PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Content Preview
              Text(
                previewContent,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Bottom row: Status badge + Timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: status),
                  Text(
                    timestamp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
