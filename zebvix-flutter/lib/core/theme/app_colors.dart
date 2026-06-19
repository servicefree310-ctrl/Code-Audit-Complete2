import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFFFCD535);
  static const Color secondary = Color(0xFF111827);
  static const Color background = Color(0xFF0B0E11);
  static const Color surface = Color(0xFF1E2329);
  static const Color surfaceLight = Color(0xFF2B3139);
  static const Color accent = Color(0xFF1E2329);

  // Text colors
  static const Color textPrimary = Color(0xFFEAEBED);
  static const Color textSecondary = Color(0xFF848E9C);
  static const Color textHint = Color(0xFF5E6673);
  static const Color textDark = Color(0xFF0B0E11);

  // State colors
  static const Color success = Color(0xFF0ECB81);
  static const Color error = Color(0xFFF6465D);
  static const Color warning = Color(0xFFF0B90B);
  static const Color info = Color(0xFF1DA2B4);

  // Trading colors
  static const Color bullish = Color(0xFF0ECB81);
  static const Color bearish = Color(0xFFF6465D);
  static const Color neutral = Color(0xFF848E9C);

  // Surface aliases (used by widgets)
  static const Color surface2   = Color(0xFF2B3139);
  static const Color surface3   = Color(0xFF363C45);
  static const Color border     = Color(0xFF2B3139);

  // Text aliases
  static const Color textTertiary = Color(0xFF5E6673);

  // Border
  static const Color borderColor = Color(0xFF2B3139);
  static const Color borderLight = Color(0xFF363C45);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFCD535), Color(0xFFF0B90B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B0E11), Color(0xFF1E2329)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2329), Color(0xFF2B3139)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFCD535), Color(0xFFFFAA00), Color(0xFFFCD535)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient greenGradient = LinearGradient(
    colors: [const Color(0xFF0ECB81).withOpacity(0.2), const Color(0xFF0ECB81).withOpacity(0.05)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient redGradient = LinearGradient(
    colors: [const Color(0xFFF6465D).withOpacity(0.2), const Color(0xFFF6465D).withOpacity(0.05)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism
  static Color glass = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFFFCD535),
    Color(0xFF0ECB81),
    Color(0xFF1DA2B4),
    Color(0xFFF6465D),
    Color(0xFFB7BDC6),
    Color(0xFF9B59B6),
  ];
}
