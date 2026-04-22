import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ScriptStatus { draft, ready, outline }

class StatusBadge extends StatelessWidget {
  final ScriptStatus status;
  
  const StatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case ScriptStatus.ready:
        bgColor = AppColors.accentGreen.withValues(alpha: 0.15);
        textColor = AppColors.accentGreen;
        label = 'Ready';
        break;
      case ScriptStatus.outline:
        bgColor = AppColors.accentBlue.withValues(alpha: 0.15);
        textColor = AppColors.accentBlue;
        label = 'Outline';
        break;
      case ScriptStatus.draft:
        bgColor = AppColors.textSecondary.withValues(alpha: 0.15);
        textColor = AppColors.textSecondary;
        label = 'Draft';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
