import 'package:musikita/core/theme/app_theme.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.themeMode,
    required super.colorScheme,
    required super.enabledCodecs,
    required super.crossfadeDuration,
    required super.sleepTimer,
    required super.isShuffled,
    required super.repeatMode,
    required super.showLyrics,
    required super.volume,
    super.backupAccount,
    required super.autoBackup,
    super.showHiddenTracks,
    super.fontFamily,
    super.customPrimaryColorValue,
    super.customSecondaryColorValue,
    super.navbarElevation,
    super.playerOpacity,
    super.useMaterialYou,
  });

  factory AppSettingsModel.defaults() {
    return AppSettingsModel(
      themeMode: AppThemeMode.system,
      colorScheme: AppColorScheme.blue,
      enabledCodecs: const ['.mp3', '.flac', '.aac', '.ogg', '.m4a'],
      crossfadeDuration: 0,
      sleepTimer: SleepTimerDuration.off,
      isShuffled: false,
      repeatMode: RepeatMode.off,
      showLyrics: true,
      volume: 1.0,
      autoBackup: false,
      showHiddenTracks: false,
      useMaterialYou: false,
    );
  }

  factory AppSettingsModel.fromEntity(AppSettings entity) {
    return AppSettingsModel(
      themeMode: entity.themeMode,
      colorScheme: entity.colorScheme,
      enabledCodecs: entity.enabledCodecs,
      crossfadeDuration: entity.crossfadeDuration,
      sleepTimer: entity.sleepTimer,
      isShuffled: entity.isShuffled,
      repeatMode: entity.repeatMode,
      showLyrics: entity.showLyrics,
      volume: entity.volume,
      backupAccount: entity.backupAccount,
      autoBackup: entity.autoBackup,
      showHiddenTracks: entity.showHiddenTracks,
      fontFamily: entity.fontFamily,
      customPrimaryColorValue: entity.customPrimaryColorValue,
      customSecondaryColorValue: entity.customSecondaryColorValue,
      navbarElevation: entity.navbarElevation,
      playerOpacity: entity.playerOpacity,
      useMaterialYou: entity.useMaterialYou,
    );
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      themeMode: _parseThemeMode(map['theme_mode'] as String?),
      colorScheme: _parseColorScheme(map['color_scheme'] as String?),
      enabledCodecs: List<String>.from(map['enabled_codecs'] as List<dynamic>? ?? const []),
      crossfadeDuration: map['crossfade_duration'] as int? ?? 0,
      sleepTimer: _parseSleepTimer(map['sleep_timer'] as String?),
      isShuffled: map['is_shuffled'] as bool? ?? false,
      repeatMode: _parseRepeatMode(map['repeat_mode'] as String?),
      showLyrics: map['show_lyrics'] as bool? ?? true,
      volume: (map['volume'] as num?)?.toDouble() ?? 1.0,
      backupAccount: map['backup_account'] as String?,
      autoBackup: map['auto_backup'] as bool? ?? false,
      showHiddenTracks: map['show_hidden_tracks'] as bool? ?? false,
      fontFamily: map['font_family'] as String?,
      customPrimaryColorValue: map['custom_primary_color'] as int?,
      customSecondaryColorValue: map['custom_secondary_color'] as int?,
      navbarElevation: (map['navbar_elevation'] as num?)?.toDouble(),
      playerOpacity: (map['player_opacity'] as num?)?.toDouble(),
      useMaterialYou: map['use_material_you'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme_mode': themeMode.name,
      'color_scheme': colorScheme.name,
      'enabled_codecs': enabledCodecs,
      'crossfade_duration': crossfadeDuration,
      'sleep_timer': sleepTimer.name,
      'is_shuffled': isShuffled,
      'repeat_mode': repeatMode.name,
      'show_lyrics': showLyrics,
      'volume': volume,
      'backup_account': backupAccount,
      'auto_backup': autoBackup,
      'show_hidden_tracks': showHiddenTracks,
      'font_family': fontFamily,
      'custom_primary_color': customPrimaryColorValue,
      'custom_secondary_color': customSecondaryColorValue,
      'navbar_elevation': navbarElevation,
      'player_opacity': playerOpacity,
      'use_material_you': useMaterialYou,
    };
  }

  AppSettings toEntity() {
    return AppSettings(
      themeMode: themeMode,
      colorScheme: colorScheme,
      enabledCodecs: enabledCodecs,
      crossfadeDuration: crossfadeDuration,
      sleepTimer: sleepTimer,
      isShuffled: isShuffled,
      repeatMode: repeatMode,
      showLyrics: showLyrics,
      volume: volume,
      backupAccount: backupAccount,
      autoBackup: autoBackup,
      showHiddenTracks: showHiddenTracks,
      fontFamily: fontFamily,
      customPrimaryColorValue: customPrimaryColorValue,
      customSecondaryColorValue: customSecondaryColorValue,
      navbarElevation: navbarElevation,
      playerOpacity: playerOpacity,
      useMaterialYou: useMaterialYou,
    );
  }

  static AppThemeMode _parseThemeMode(String? value) {
    if (value == null) return AppThemeMode.system;
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeMode.system,
    );
  }

  static AppColorScheme _parseColorScheme(String? value) {
    if (value == null) return AppColorScheme.blue;
    return AppColorScheme.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppColorScheme.blue,
    );
  }

  static SleepTimerDuration _parseSleepTimer(String? value) {
    if (value == null) return SleepTimerDuration.off;
    return SleepTimerDuration.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SleepTimerDuration.off,
    );
  }

  static RepeatMode _parseRepeatMode(String? value) {
    if (value == null) return RepeatMode.off;
    return RepeatMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RepeatMode.off,
    );
  }
}
