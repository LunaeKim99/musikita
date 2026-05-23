import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/data/datasources/local_datasource.dart';
import 'package:musikita/features/music_player/data/models/playlist_model.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final LocalDataSource _localDataSource;

  PlaylistRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Playlist>>> getPlaylists() async {
    try {
      final playlists = await _localDataSource.getPlaylists();
      return Right(playlists.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Playlist>> createPlaylist(String name) async {
    try {
      final playlist = PlaylistModel(name: name, createdAt: DateTime.now());
      final id = await _localDataSource.insertPlaylist(playlist);
      final created = PlaylistModel(
        id: id,
        name: name,
        createdAt: playlist.createdAt,
        songCount: 0,
      );
      return Right(created.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(int id) async {
    try {
      await _localDataSource.deletePlaylist(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Playlist>> renamePlaylist(int id, String newName) async {
    try {
      final existing = await _localDataSource.getPlaylistById(id);
      if (existing == null) {
        return const Left(DatabaseFailure('Playlist not found'));
      }
      final updated = PlaylistModel(
        id: existing.id,
        name: newName.trim().isEmpty ? existing.name : newName.trim(),
        createdAt: existing.createdAt,
        songCount: existing.songCount,
      );
      await _localDataSource.updatePlaylist(updated);
      return Right(updated.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Song>>> getPlaylistSongs(int playlistId) async {
    try {
      final songs = await _localDataSource.getPlaylistSongs(playlistId);
      return Right(songs.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addSongToPlaylist(int playlistId, int songId) async {
    try {
      await _localDataSource.addSongToPlaylist(playlistId, songId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeSongFromPlaylist(int playlistId, int songId) async {
    try {
      await _localDataSource.removeSongFromPlaylist(playlistId, songId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
