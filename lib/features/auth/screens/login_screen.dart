import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = kIsWeb || MediaQuery.of(context).size.width >= 900;
    
    Widget content = _buildLoginCard(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: isDesktop
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: content,
              ),
            )
          : SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: content,
                ),
              ),
            ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blue gradient top accent line
          Container(
            height: 2,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ScriptFlow',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () {
                        // Close action
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your creative journey.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // SSO Buttons
                _SsoButton(
                  icon: Icons.g_mobiledata, // Placeholder for Google
                  label: 'Continue with Google',
                  onTap: () {
                    context.go('/onboarding');
                  },
                ),
                const SizedBox(height: 16),
                _SsoButton(
                  icon: Icons.auto_awesome, // Placeholder for Gemini
                  label: 'Continue with Gemini',
                  onTap: () {
                    context.go('/onboarding');
                  },
                ),
                const SizedBox(height: 16),
                _SsoButton(
                  icon: Icons.code, // Placeholder for Claude
                  label: 'Continue with Claude',
                  onTap: () {
                    context.go('/onboarding');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SsoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SsoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.textPrimary),
      label: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.bgElevated,
      ),
    );
  }
}
