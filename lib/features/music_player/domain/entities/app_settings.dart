import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:musikita/core/theme/app_theme.dart';

enum RepeatMode {
  off,
  one,
  all,
}

enum SleepTimerDuration {
  off,
  fifteen,
  thirty,
  sixty,
  endOfSong,
}

class AppSettings extends Equatable {
  final AppThemeMode themeMode;
  final AppColorScheme colorScheme;
  final List<String> enabledCodecs;
  final int crossfadeDuration;
  final SleepTimerDuration sleepTimer;
  final bool isShuffled;
  final RepeatMode repeatMode;
  final bool showLyrics;
  final double volume;
  final String? backupAccount;
  final bool autoBackup;
  final bool showHiddenTracks;
  final String? fontFamily;
  final int? customPrimaryColorValue;
  final int? customSecondaryColorValue;
  final double? navbarElevation;
  final double? playerOpacity;
  final bool useMaterialYou;

  const AppSettings({
    required this.themeMode,
    required this.colorScheme,
    required this.enabledCodecs,
    required this.crossfadeDuration,
    required this.sleepTimer,
    required this.isShuffled,
    required this.repeatMode,
    required this.showLyrics,
    required this.volume,
    this.backupAccount,
    required this.autoBackup,
    this.showHiddenTracks = false,
    this.fontFamily,
    this.customPrimaryColorValue,
    this.customSecondaryColorValue,
    this.navbarElevation,
    this.playerOpacity,
    this.useMaterialYou = false,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppColorScheme? colorScheme,
    List<String>? enabledCodecs,
    int? crossfadeDuration,
    SleepTimerDuration? sleepTimer,
    bool? isShuffled,
    RepeatMode? repeatMode,
    bool? showLyrics,
    double? volume,
    String? backupAccount,
    bool? autoBackup,
    bool? showHiddenTracks,
    String? fontFamily,
    int? customPrimaryColorValue,
    int? customSecondaryColorValue,
    double? navbarElevation,
    double? playerOpacity,
    bool? useMaterialYou,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      colorScheme: colorScheme ?? this.colorScheme,
      enabledCodecs: enabledCodecs ?? this.enabledCodecs,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      sleepTimer: sleepTimer ?? this.sleepTimer,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      showLyrics: showLyrics ?? this.showLyrics,
      volume: volume ?? this.volume,
      backupAccount: backupAccount ?? this.backupAccount,
      autoBackup: autoBackup ?? this.autoBackup,
      showHiddenTracks: showHiddenTracks ?? this.showHiddenTracks,
      fontFamily: fontFamily ?? this.fontFamily,
      customPrimaryColorValue: customPrimaryColorValue ?? this.customPrimaryColorValue,
      customSecondaryColorValue: customSecondaryColorValue ?? this.customSecondaryColorValue,
      navbarElevation: navbarElevation ?? this.navbarElevation,
      playerOpacity: playerOpacity ?? this.playerOpacity,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
    );
  }

  Color? get customPrimaryColor => customPrimaryColorValue != null
      ? Color(customPrimaryColorValue!)
      : null;

  Color? get customSecondaryColor => customSecondaryColorValue != null
      ? Color(customSecondaryColorValue!)
      : null;

  @override
  List<Object?> get props => [
        themeMode,
        colorScheme,
        enabledCodecs,
        crossfadeDuration,
        sleepTimer,
        isShuffled,
        repeatMode,
        showLyrics,
        volume,
        backupAccount,
        autoBackup,
        showHiddenTracks,
        fontFamily,
        customPrimaryColorValue,
        customSecondaryColorValue,
        navbarElevation,
        playerOpacity,
        useMaterialYou,
      ];
}
