import 'package:flutter/material.dart';

import '../../core/config/env_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Profile & Settings. Local-first: there is no cloud account, so this surfaces
/// workspace prefs + AI status. A local display name/bio can be added later.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionCard(
            title: 'Workspace',
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Auto-Save Scripts'),
                subtitle: Text('Edits persist to the local database.'),
                trailing:
                    Icon(Icons.check_circle, color: AppColors.recordGreen),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('AI Suggestions (The Muse)'),
                subtitle: Text(
                  EnvConfig.isConfigured
                      ? 'Connected to ${EnvConfig.geminiModel}.'
                      : 'No API key — add GEMINI_API_KEY to .env.',
                ),
                trailing: Icon(
                  EnvConfig.isConfigured ? Icons.check_circle : Icons.error,
                  color: EnvConfig.isConfigured
                      ? AppColors.recordGreen
                      : AppColors.warning,
                ),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Storage'),
                subtitle: Text('Scripts & recordings stored on-device only.'),
                trailing: Icon(Icons.smartphone, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'About',
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppConstants.appName),
                subtitle: Text(AppConstants.tagline),
                trailing: Text('v0.1.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
