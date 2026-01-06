import 'package:flutter/material.dart';

/// SkillBridge App Theme Configuration
/// Teal & Orange – professional, modern, calming
class AppTheme {
  AppTheme._();

  static AppThemeColors colors = TealOrangeTheme();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surface,
        error: colors.error,
        onPrimary: colors.onPrimary,
        onSecondary: colors.onSecondary,
        onSurface: colors.onSurface,
        onError: colors.onError,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surfaceDark,
        error: colors.error,
        onPrimary: colors.onPrimary,
        onSecondary: colors.onSecondary,
        onSurface: colors.onSurfaceDark,
        onError: colors.onError,
      ),
      scaffoldBackgroundColor: colors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

abstract class AppThemeColors {
  Color get primary;
  Color get primaryLight;
  Color get primaryDark;

  Color get secondary;
  Color get secondaryLight;
  Color get secondaryDark;

  Color get surface;
  Color get surfaceDark;

  Color get background;
  Color get backgroundDark;

  Color get onPrimary;
  Color get onSecondary;
  Color get onSurface;
  Color get onSurfaceDark;
  Color get onBackground;
  Color get onBackgroundDark;

  Color get error;
  Color get onError;
  Color get success;
  Color get warning;
  Color get info;

  Color get jobCardPrimary;
  Color get jobCardSecondary;

  Color get navActive;
  Color get navInactive;
}

class TealOrangeTheme implements AppThemeColors {
  @override
  Color get primary => const Color(0xFF008080);
  @override
  Color get primaryLight => const Color(0xFF4DB3B3);
  @override
  Color get primaryDark => const Color(0xFF005252);

  @override
  Color get secondary => const Color(0xFFFF6B35);
  @override
  Color get secondaryLight => const Color(0xFFFF8C66);
  @override
  Color get secondaryDark => const Color(0xFFCC5529);

  @override
  Color get surface => Colors.white;
  @override
  Color get surfaceDark => const Color(0xFF1E1E1E);

  @override
  Color get background => const Color(0xFFF5F5F5);
  @override
  Color get backgroundDark => const Color(0xFF121212);

  @override
  Color get onPrimary => Colors.white;
  @override
  Color get onSecondary => Colors.white;
  @override
  Color get onSurface => Colors.black87;
  @override
  Color get onSurfaceDark => Colors.white;
  @override
  Color get onBackground => Colors.black87;
  @override
  Color get onBackgroundDark => Colors.white;

  @override
  Color get error => const Color(0xFFD32F2F);
  @override
  Color get onError => Colors.white;
  @override
  Color get success => const Color(0xFF388E3C);
  @override
  Color get warning => const Color(0xFFF57C00);
  @override
  Color get info => const Color(0xFF1976D2);

  @override
  Color get jobCardPrimary => const Color(0xFFFFE5D9);
  @override
  Color get jobCardSecondary => const Color(0xFFE0F7F7);

  @override
  Color get navActive => const Color(0xFF008080);
  @override
  Color get navInactive => const Color(0xFF9E9E9E);
}

