import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark,
  amoled,
}

class AppTheme {
  static ThemeData light() {
    return FlexThemeData.light(
      scheme: FlexScheme.blue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return FlexThemeData.dark(
      scheme: FlexScheme.blue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 14,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
    );
  }

  static ThemeData amoled() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        surface: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
      useMaterial3: true,
    );
  }
}
