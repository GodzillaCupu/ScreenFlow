import 'package:flutter/material.dart';

import '../../core/config/env_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/layout/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';

/// Profile & Settings. Local-first: there is no cloud account, so this surfaces
/// workspace prefs + AI status. A local display name/bio can be added later.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AdaptiveLayout.isDesktop(context);

    final content = ListView(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      children: [
        if (isDesktop)
          Text(
            'Profile & Settings',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28),
          ),
        if (isDesktop) const SizedBox(height: 32),
        
        // Profile Block
        _SectionCard(
          title: 'Account Profile',
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.accentBlue,
                  radius: 32,
                  child: Icon(Icons.person, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Creator',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pro Plan (Local-First)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        _SectionCard(
          title: 'Workspace Preferences',
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Auto-Save Scripts'),
              subtitle: Text('Edits persist to the local database.'),
              trailing: Icon(Icons.check_circle, color: AppColors.recordGreen),
            ),
            const Divider(color: AppColors.border),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Storage'),
              subtitle: Text('Scripts & recordings stored on-device only.'),
              trailing: Icon(Icons.smartphone, color: AppColors.textSecondary),
            ),
            const Divider(color: AppColors.border),
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
          ],
        ),
        const SizedBox(height: 24),

        _SectionCard(
          title: 'Integrations',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.video_library, color: AppColors.accentRed),
              title: const Text('YouTube Studio'),
              subtitle: const Text('Not connected'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Connect', style: TextStyle(color: AppColors.accentBlue)),
              ),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_upload, color: AppColors.accentBlue),
              title: const Text('Google Drive Backup'),
              subtitle: const Text('Not connected'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Connect', style: TextStyle(color: AppColors.accentBlue)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        _SectionCard(
          title: 'Danger Zone',
          borderColor: AppColors.danger.withValues(alpha: 0.3),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Delete All Data', style: TextStyle(color: AppColors.danger)),
              subtitle: const Text('Permanently remove all scripts and recordings from this device.'),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                  foregroundColor: AppColors.danger,
                  elevation: 0,
                ),
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
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
    );

    if (isDesktop) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: content,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: content,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children, this.borderColor});
  final String title;
  final List<Widget> children;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

