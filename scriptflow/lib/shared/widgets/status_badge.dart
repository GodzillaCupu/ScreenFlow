import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/script.dart';

/// Pill showing a script's lifecycle status. Uses the single [ScriptStatus]
/// enum defined on the Script model (drafting / review / readyToRecord /
/// approved) so UI and storage never drift apart.
class StatusBadge extends StatelessWidget {
  final ScriptStatus status;

  const StatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      ScriptStatus.drafting => (AppColors.statusDrafting, 'Draft'),
      ScriptStatus.review => (AppColors.statusReview, 'Review'),
      ScriptStatus.readyToRecord => (AppColors.statusReady, 'Ready'),
      ScriptStatus.approved => (AppColors.statusApproved, 'Approved'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
