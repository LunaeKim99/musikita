import 'package:equatable/equatable.dart';
import 'package:musikita/core/theme/app_theme.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  const SettingsLoaded(this.settings);

  AppThemeMode get themeMode => settings.themeMode;
  List<String> get enabledCodecs => settings.enabledCodecs;
  int get crossfadeDuration => settings.crossfadeDuration;
  SleepTimerDuration get sleepTimer => settings.sleepTimer;
  bool get showLyrics => settings.showLyrics;
  double get volume => settings.volume;
  bool get autoBackup => settings.autoBackup;

  SettingsLoaded copyWith({
    AppSettings? settings,
  }) {
    return SettingsLoaded(settings ?? this.settings);
  }

  @override
  List<Object?> get props => [settings];
}

class ExportInProgress extends SettingsState {}

class ExportComplete extends SettingsState {
  final String jsonPath;
  final String jsonContent;

  const ExportComplete({
    required this.jsonPath,
    required this.jsonContent,
  });

  @override
  List<Object?> get props => [jsonPath, jsonContent];
}

class ImportInProgress extends SettingsState {}

class ImportComplete extends SettingsState {
  final int importedSongsCount;

  const ImportComplete(this.importedSongsCount);

  @override
  List<Object?> get props => [importedSongsCount];
}

class ImportFilePicked extends SettingsState {
  final String filePath;
  final String jsonContent;

  const ImportFilePicked({
    required this.filePath,
    required this.jsonContent,
  });

  @override
  List<Object?> get props => [filePath, jsonContent];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
