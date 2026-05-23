import 'package:equatable/equatable.dart';
import 'package:musikita/core/theme/app_theme.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateThemeMode extends SettingsEvent {
  final AppThemeMode themeMode;

  const UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateEnabledCodecs extends SettingsEvent {
  final List<String> enabledCodecs;

  const UpdateEnabledCodecs(this.enabledCodecs);

  @override
  List<Object?> get props => [enabledCodecs];
}

class UpdateCrossfadeDuration extends SettingsEvent {
  final int seconds;

  const UpdateCrossfadeDuration(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class UpdateSleepTimer extends SettingsEvent {
  final SleepTimerDuration timer;

  const UpdateSleepTimer(this.timer);

  @override
  List<Object?> get props => [timer];
}

class UpdateShowLyrics extends SettingsEvent {
  final bool show;

  const UpdateShowLyrics(this.show);

  @override
  List<Object?> get props => [show];
}

class UpdateVolume extends SettingsEvent {
  final double volume;

  const UpdateVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ToggleAutoBackup extends SettingsEvent {
  const ToggleAutoBackup();
}

class ExportDataEvent extends SettingsEvent {
  const ExportDataEvent();
}

class ImportDataEvent extends SettingsEvent {
  final String jsonString;

  const ImportDataEvent(this.jsonString);

  @override
  List<Object?> get props => [jsonString];
}

class PickImportFile extends SettingsEvent {
  const PickImportFile();
}

class ResetAllSettings extends SettingsEvent {
  const ResetAllSettings();
}
