import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark,
  amoled,
  dynamicLight,
  dynamicDark,
}

enum AppColorScheme {
  blue,
  purple,
  red,
  pink,
  orange,
  green,
  teal,
  cyan,
}

class AppTheme {
  static Color _seedColorForScheme(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.purple:
        return Colors.purple;
      case AppColorScheme.red:
        return Colors.red;
      case AppColorScheme.pink:
        return Colors.pink;
      case AppColorScheme.orange:
        return Colors.orange;
      case AppColorScheme.green:
        return Colors.green;
      case AppColorScheme.teal:
        return Colors.teal;
      case AppColorScheme.cyan:
        return Colors.cyan;
      case AppColorScheme.blue:
        return Colors.blue;
    }
  }

  static ThemeData light({
    AppColorScheme colorScheme = AppColorScheme.blue,
    Color? primaryColor,
    Color? secondaryColor,
    String? fontFamily,
    double? navbarElevation,
    double? playerOpacity,
  }) {
    final seedColor = primaryColor ?? _seedColorForScheme(colorScheme);
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      fontFamily: fontFamily,
    );

    return _customizeTheme(
      baseTheme,
      navbarElevation: navbarElevation,
      playerOpacity: playerOpacity,
    );
  }

  static ThemeData dark({
    AppColorScheme colorScheme = AppColorScheme.blue,
    Color? primaryColor,
    Color? secondaryColor,
    String? fontFamily,
    double? navbarElevation,
    double? playerOpacity,
  }) {
    final seedColor = primaryColor ?? _seedColorForScheme(colorScheme);
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      fontFamily: fontFamily,
    );

    return _customizeTheme(
      baseTheme,
      navbarElevation: navbarElevation,
      playerOpacity: playerOpacity,
    );
  }

  static ThemeData amoled({
    Color? primaryColor,
    Color? secondaryColor,
    String? fontFamily,
    double? navbarElevation,
    double? playerOpacity,
  }) {
    final baseTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor ?? Colors.blue,
        brightness: Brightness.dark,
        surface: Colors.black,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: Colors.black,
      useMaterial3: true,
      fontFamily: fontFamily,
    );

    return _customizeTheme(
      baseTheme,
      navbarElevation: navbarElevation,
      playerOpacity: playerOpacity,
      isAmoled: true,
    );
  }

  static ThemeData _customizeTheme(
    ThemeData baseTheme, {
    double? navbarElevation,
    double? playerOpacity,
    bool isAmoled = false,
  }) {
    CardThemeData? cardTheme;
    if (playerOpacity != null) {
      final originalCardTheme = baseTheme.cardTheme;
      final originalColor = originalCardTheme.color ?? baseTheme.colorScheme.surface;
      cardTheme = originalCardTheme.copyWith(
        color: originalColor.withValues(alpha: playerOpacity),
        elevation: isAmoled ? 0 : originalCardTheme.elevation,
      );
    } else if (isAmoled) {
      cardTheme = baseTheme.cardTheme.copyWith(
        elevation: 0,
        color: Colors.black,
      );
    }

    return baseTheme.copyWith(
      navigationBarTheme: NavigationBarThemeData(
        elevation: navbarElevation,
        backgroundColor: isAmoled ? Colors.black : baseTheme.navigationBarTheme.backgroundColor,
      ),
      cardTheme: cardTheme ?? baseTheme.cardTheme,
      appBarTheme: AppBarTheme(
        elevation: navbarElevation,
        backgroundColor: isAmoled ? Colors.black : baseTheme.appBarTheme.backgroundColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: navbarElevation,
        backgroundColor: isAmoled ? Colors.black : baseTheme.bottomNavigationBarTheme.backgroundColor,
      ),
    );
  }
}
