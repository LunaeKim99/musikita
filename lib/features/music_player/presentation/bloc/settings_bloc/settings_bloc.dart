import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:musikita/core/constants/app_constants.dart';
import 'package:musikita/core/theme/app_theme.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';
import 'package:musikita/features/music_player/domain/usecases/export_data.dart';
import 'package:musikita/features/music_player/domain/usecases/get_settings.dart';
import 'package:musikita/features/music_player/domain/usecases/import_data.dart';
import 'package:musikita/features/music_player/domain/usecases/update_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings _getSettings;
  final UpdateSettings _updateSettings;
  final ExportData _exportData;
  final ImportData _importData;

  SettingsBloc({
    required this._getSettings,
    required this._updateSettings,
    required this._exportData,
    required this._importData,
  }) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateEnabledCodecs>(_onUpdateEnabledCodecs);
    on<UpdateCrossfadeDuration>(_onUpdateCrossfadeDuration);
    on<UpdateSleepTimer>(_onUpdateSleepTimer);
    on<UpdateShowLyrics>(_onUpdateShowLyrics);
    on<UpdateVolume>(_onUpdateVolume);
    on<ToggleAutoBackup>(_onToggleAutoBackup);
    on<ExportDataEvent>(_onExportData);
    on<ImportDataEvent>(_onImportData);
    on<PickImportFile>(_onPickImportFile);
    on<ResetAllSettings>(_onResetAllSettings);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await _getSettings();
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) {
        emit(SettingsLoaded(settings));
      },
    );
  }

  Future<void> _onUpdateThemeMode(UpdateThemeMode event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      final updated = current.settings.copyWith(themeMode: event.themeMode);

      final result = await _updateSettings(updated);
      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(SettingsLoaded(updated)),
      );
    }
  }

  Future<void> _onUpdateEnabledCodecs(UpdateEnabledCodecs event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      final updated = current.settings.copyWith(enabledCodecs: event.enabledCodecs);

      final result = await _updateSettings(updated);
      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(SettingsLoaded(updated)),
      );
    }
  }

  Future<void> _onUpdateCrossfadeDuration(UpdateCrossfadeDuration event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      final updated = current.settings.copyWith(crossfadeDuration: event.seconds);

      final result = await _updateSettings(updated);
      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(SettingsLoaded(updated)),
      );
    }
  }

  Future<void> _onUpdateSleepTimer(UpdateSleepTimer event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      final updated = current.settings.copyWith(sleepTimer: event.timer);

      final result = await _updateSettings(updated);
      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(SettingsLoaded(updated)),
      );
    }
  }

  Future<void> _onUpdateShowLyrics(UpdateShowLyrics event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      final updated = current.settings.copyWith(showLyrics: event.show);

      final result = await _updateSettings(updated);
      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(SettingsLoaded(updated)),
      );
    }
  }

  Future<void> _onUpdateVolume(UpdateVolume event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      final updated = current.settings.copyWith(volume: event.volume);

      final result = await _updateSettings(updated);
      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(SettingsLoaded(updated)),
      );
    }
  }

  Future<void> _onToggleAutoBackup(ToggleAutoBackup event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      final updated = current.settings.copyWith(autoBackup: !current.settings.autoBackup);

      final result = await _updateSettings(updated);
      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(SettingsLoaded(updated)),
      );
    }
  }

  Future<void> _onExportData(ExportDataEvent event, Emitter<SettingsState> emit) async {
    emit(ExportInProgress());

    final result = await _exportData();
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (jsonContent) async {
        try {
          final tempDir = await getTemporaryDirectory();
          final exportDir = Directory('${tempDir.path}/exports');
          if (!await exportDir.exists()) {
            await exportDir.create(recursive: true);
          }

          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'musikita_backup_$timestamp.json';
          final filePath = '${exportDir.path}/$fileName';

          final file = File(filePath);
          await file.writeAsString(jsonContent);

          emit(ExportComplete(
            jsonPath: filePath,
            jsonContent: jsonContent,
          ));
        } catch (e) {
          emit(SettingsError('Failed to save export file: $e'));
        }
      },
    );
  }

  Future<void> _onPickImportFile(PickImportFile event, Emitter<SettingsState> emit) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final jsonContent = await file.readAsString();
        emit(ImportFilePicked(
          filePath: file.path,
          jsonContent: jsonContent,
        ));
      }
    } catch (e) {
      emit(SettingsError('Failed to pick file: $e'));
    }
  }

  Future<void> _onImportData(ImportDataEvent event, Emitter<SettingsState> emit) async {
    emit(ImportInProgress());

    final result = await _importData(event.jsonString);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (count) async {
        final reloadResult = await _getSettings();
        reloadResult.fold(
          (failure) => emit(ImportComplete(count)),
          (settings) {
            emit(ImportComplete(count));
            emit(SettingsLoaded(settings));
          },
        );
      },
    );
  }

  Future<void> _onResetAllSettings(ResetAllSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());

    final defaultSettings = AppSettings(
      themeMode: AppThemeMode.system,
      enabledCodecs: AppConstants.defaultCodecs,
      crossfadeDuration: 0,
      sleepTimer: SleepTimerDuration.off,
      isShuffled: false,
      repeatMode: RepeatMode.off,
      showLyrics: true,
      volume: 1.0,
      autoBackup: false,
    );

    final result = await _updateSettings(defaultSettings);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) {
        emit(SettingsLoaded(defaultSettings));
      },
    );
  }
}
