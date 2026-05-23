import 'package:musikita/core/theme/app_theme.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.themeMode,
    required super.enabledCodecs,
    required super.crossfadeDuration,
    required super.sleepTimer,
    required super.isShuffled,
    required super.repeatMode,
    required super.showLyrics,
    required super.volume,
    super.backupAccount,
    required super.autoBackup,
  });

  factory AppSettingsModel.defaults() {
    return AppSettingsModel(
      themeMode: AppThemeMode.system,
      enabledCodecs: const ['.mp3', '.flac', '.aac', '.ogg', '.m4a'],
      crossfadeDuration: 0,
      sleepTimer: SleepTimerDuration.off,
      isShuffled: false,
      repeatMode: RepeatMode.off,
      showLyrics: true,
      volume: 1.0,
      autoBackup: false,
    );
  }

  factory AppSettingsModel.fromEntity(AppSettings entity) {
    return AppSettingsModel(
      themeMode: entity.themeMode,
      enabledCodecs: entity.enabledCodecs,
      crossfadeDuration: entity.crossfadeDuration,
      sleepTimer: entity.sleepTimer,
      isShuffled: entity.isShuffled,
      repeatMode: entity.repeatMode,
      showLyrics: entity.showLyrics,
      volume: entity.volume,
      backupAccount: entity.backupAccount,
      autoBackup: entity.autoBackup,
    );
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      themeMode: _parseThemeMode(map['theme_mode'] as String?),
      enabledCodecs: List<String>.from(map['enabled_codecs'] as List<dynamic>? ?? const []),
      crossfadeDuration: map['crossfade_duration'] as int? ?? 0,
      sleepTimer: _parseSleepTimer(map['sleep_timer'] as String?),
      isShuffled: map['is_shuffled'] as bool? ?? false,
      repeatMode: _parseRepeatMode(map['repeat_mode'] as String?),
      showLyrics: map['show_lyrics'] as bool? ?? true,
      volume: (map['volume'] as num?)?.toDouble() ?? 1.0,
      backupAccount: map['backup_account'] as String?,
      autoBackup: map['auto_backup'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme_mode': themeMode.name,
      'enabled_codecs': enabledCodecs,
      'crossfade_duration': crossfadeDuration,
      'sleep_timer': sleepTimer.name,
      'is_shuffled': isShuffled,
      'repeat_mode': repeatMode.name,
      'show_lyrics': showLyrics,
      'volume': volume,
      'backup_account': backupAccount,
      'auto_backup': autoBackup,
    };
  }

  AppSettings toEntity() {
    return AppSettings(
      themeMode: themeMode,
      enabledCodecs: enabledCodecs,
      crossfadeDuration: crossfadeDuration,
      sleepTimer: sleepTimer,
      isShuffled: isShuffled,
      repeatMode: repeatMode,
      showLyrics: showLyrics,
      volume: volume,
      backupAccount: backupAccount,
      autoBackup: autoBackup,
    );
  }

  static AppThemeMode _parseThemeMode(String? value) {
    if (value == null) return AppThemeMode.system;
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeMode.system,
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
