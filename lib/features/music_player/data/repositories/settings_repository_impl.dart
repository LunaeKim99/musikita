import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/data/datasources/local_datasource.dart';
import 'package:musikita/features/music_player/data/datasources/settings_datasource.dart';
import 'package:musikita/features/music_player/data/models/app_settings_model.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';
import 'package:musikita/features/music_player/domain/repositories/settings_repository.dart';
import 'package:musikita/features/music_player/utils/export_import_helper.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _settingsDataSource;
  final LocalDataSource _localDataSource;

  SettingsRepositoryImpl({
    required this._settingsDataSource,
    required this._localDataSource,
  });

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settings = await _settingsDataSource.getSettings();
      return Right(settings.toEntity());
    } on SettingsException catch (e) {
      return Left(SettingsFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(AppSettings settings) async {
    try {
      await _settingsDataSource.saveSettings(AppSettingsModel.fromEntity(settings));
      return const Right(null);
    } on SettingsException catch (e) {
      return Left(SettingsFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> exportToJson() async {
    try {
      final songs = await _localDataSource.getAllSongs();
      final playlists = await _localDataSource.getPlaylists();
      final favorites = await _localDataSource.getFavoriteSongs();
      final recentPlayed = await _localDataSource.getRecentPlayed(limit: 100);
      final settingsModel = await _settingsDataSource.getSettings();

      final jsonString = ExportImportHelper.exportToJson(
        songs: songs,
        playlists: playlists,
        favorites: favorites,
        recentPlayed: recentPlayed,
        settings: settingsModel.toEntity(),
      );

      return Right(jsonString);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on SettingsException catch (e) {
      return Left(SettingsFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> importFromJson(String jsonString) async {
    try {
      final imported = ExportImportHelper.importFromJson(jsonString);
      int importedCount = 0;

      for (final song in imported.songs) {
        await _localDataSource.insertSong(song);
        importedCount++;
      }

      final existingIds = <int, int>{};
      for (final playlist in imported.playlists) {
        final newId = await _localDataSource.insertPlaylist(playlist);
        existingIds[playlist.id!] = newId;
      }

      for (final songId in imported.favoriteSongIds) {
        final song = await _localDataSource.getSongById(songId);
        if (song != null) {
          await _localDataSource.addFavorite(songId);
        }
      }

      if (imported.settings != null) {
        await _settingsDataSource.saveSettings(AppSettingsModel.fromEntity(imported.settings!));
      }

      return Right(importedCount);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on SettingsException catch (e) {
      return Left(SettingsFailure(e.message));
    }
  }
}
