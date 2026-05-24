import 'package:flutter/material.dart';

class AppColors {
  // Background Colors
  static const bgPrimary = Color(0xFF0A0A0A);
  static const bgSurface = Color(0xFF1A1A1A);
  static const bgElevated = Color(0xFF242424);
  static const bgCard = Color(0xFF1E1E1E);

  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF4B5563);

  // Accent Colors
  static const accentBlue = Color(0xFF3B82F6); // AI / primary actions
  static const accentGreen = Color(0xFF22C55E); // Record / success
  static const accentRed = Color(0xFFEF4444); // Danger / sign out

  // Borders
  static const border = Color(0xFF2D2D2D);
  static const borderSubtle = Color(0xFF1F2025);

  // ── Aliases used by the ported local-first engine (editor, teleprompter,
  // Muse panel). Mapped onto the existing palette so both naming schemes
  // resolve to one source of truth. ──
  static const bgRoot = bgPrimary;
  static const bgSidebar = bgSurface;
  static const bgInput = bgElevated;
  static const aiBlue = accentBlue; // AI / "The Muse"
  static const aiBlueBright = Color(0xFF2F80FF);
  static const recordGreen = accentGreen; // Record / Ready
  static const danger = accentRed;
  static const warning = Color(0xFFF59E0B);

  // Script lifecycle status colors.
  static const statusDrafting = warning;
  static const statusReview = accentBlue;
  static const statusReady = accentGreen;
  static const statusApproved = Color(0xFF8B5CF6);
}
