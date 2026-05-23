import 'dart:convert';
import 'package:musikita/core/constants/app_constants.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/features/music_player/data/models/app_settings_model.dart';
import 'package:musikita/features/music_player/data/models/playlist_model.dart';
import 'package:musikita/features/music_player/data/models/recent_played_model.dart';
import 'package:musikita/features/music_player/data/models/song_model.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';

class ExportImportHelper {
  static String exportToJson({
    required List<SongModel> songs,
    required List<PlaylistModel> playlists,
    required List<SongModel> favorites,
    required List<RecentPlayedModel> recentPlayed,
    required AppSettings settings,
  }) {
    try {
      final exportData = {
        'version': AppConstants.exportJsonVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'songs': songs.map((s) => s.toMap()).toList(),
        'playlists': playlists.map((p) => p.toMap()).toList(),
        'favorites': favorites.map((s) => {'song_id': s.id}).toList(),
        'recentPlayed': recentPlayed.map((r) => r.toMap()).toList(),
        'settings': AppSettingsModel.fromEntity(settings).toMap(),
      };
      return json.encode(exportData);
    } catch (e) {
      throw StorageException('Failed to export data: $e');
    }
  }

  static ImportedData importFromJson(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);

      final version = data['version'] as int? ?? 1;
      if (version > AppConstants.exportJsonVersion) {
        throw const StorageException('Backup version is newer than app version');
      }

      final songs = <SongModel>[];
      if (data['songs'] != null) {
        final songsList = data['songs'] as List;
        for (final songMap in songsList) {
          if (songMap is Map<String, dynamic>) {
            songs.add(SongModel.fromMap(songMap));
          }
        }
      }

      final playlists = <PlaylistModel>[];
      if (data['playlists'] != null) {
        final playlistsList = data['playlists'] as List;
        for (final playlistMap in playlistsList) {
          if (playlistMap is Map<String, dynamic>) {
            playlists.add(PlaylistModel.fromMap(playlistMap));
          }
        }
      }

      final favoriteSongIds = <int>[];
      if (data['favorites'] != null) {
        final favoritesList = data['favorites'] as List;
        for (final favMap in favoritesList) {
          if (favMap is Map<String, dynamic>) {
            final songId = favMap['song_id'] as int?;
            if (songId != null) {
              favoriteSongIds.add(songId);
            }
          }
        }
      }

      final recentPlayed = <RecentPlayedModel>[];
      if (data['recentPlayed'] != null) {
        final recentList = data['recentPlayed'] as List;
        for (final recentMap in recentList) {
          if (recentMap is Map<String, dynamic>) {
            recentPlayed.add(RecentPlayedModel.fromMap(recentMap));
          }
        }
      }

      AppSettings? settings;
      if (data['settings'] != null) {
        settings = AppSettingsModel.fromMap(data['settings'] as Map<String, dynamic>).toEntity();
      }

      return ImportedData(
        songs: songs,
        playlists: playlists,
        favoriteSongIds: favoriteSongIds,
        recentPlayed: recentPlayed,
        settings: settings,
      );
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to import data: $e');
    }
  }
}

class ImportedData {
  final List<SongModel> songs;
  final List<PlaylistModel> playlists;
  final List<int> favoriteSongIds;
  final List<RecentPlayedModel> recentPlayed;
  final AppSettings? settings;

  ImportedData({
    required this.songs,
    required this.playlists,
    required this.favoriteSongIds,
    required this.recentPlayed,
    this.settings,
  });
}
