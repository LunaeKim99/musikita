import 'package:equatable/equatable.dart';
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
  final List<String> enabledCodecs;
  final int crossfadeDuration;
  final SleepTimerDuration sleepTimer;
  final bool isShuffled;
  final RepeatMode repeatMode;
  final bool showLyrics;
  final double volume;
  final String? backupAccount;
  final bool autoBackup;

  const AppSettings({
    required this.themeMode,
    required this.enabledCodecs,
    required this.crossfadeDuration,
    required this.sleepTimer,
    required this.isShuffled,
    required this.repeatMode,
    required this.showLyrics,
    required this.volume,
    this.backupAccount,
    required this.autoBackup,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    List<String>? enabledCodecs,
    int? crossfadeDuration,
    SleepTimerDuration? sleepTimer,
    bool? isShuffled,
    RepeatMode? repeatMode,
    bool? showLyrics,
    double? volume,
    String? backupAccount,
    bool? autoBackup,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      enabledCodecs: enabledCodecs ?? this.enabledCodecs,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      sleepTimer: sleepTimer ?? this.sleepTimer,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      showLyrics: showLyrics ?? this.showLyrics,
      volume: volume ?? this.volume,
      backupAccount: backupAccount ?? this.backupAccount,
      autoBackup: autoBackup ?? this.autoBackup,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        enabledCodecs,
        crossfadeDuration,
        sleepTimer,
        isShuffled,
        repeatMode,
        showLyrics,
        volume,
        backupAccount,
        autoBackup,
      ];
}
