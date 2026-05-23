import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/data/datasources/audio_scan_datasource.dart';
import 'package:musikita/features/music_player/data/datasources/local_datasource.dart';
import 'package:musikita/features/music_player/data/models/song_model.dart';
import 'package:musikita/features/music_player/domain/entities/recent_played.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/song_repository.dart';

class SongRepositoryImpl implements SongRepository {
  final LocalDataSource _localDataSource;
  final AudioScanDataSource _audioScanDataSource;

  SongRepositoryImpl({
    required this._localDataSource,
    required this._audioScanDataSource,
  });

  @override
  Future<Either<Failure, List<Song>>> getSongs({bool showHidden = false}) async {
    try {
      final songs = await _localDataSource.getAllSongs(showHidden: showHidden);
      return Right(songs.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Song>>> searchSongs(String query, {bool showHidden = false}) async {
    try {
      final songs = await _localDataSource.searchSongs(query, showHidden: showHidden);
      return Right(songs.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<RecentPlayed>>> getRecentPlayed({int limit = 50}) async {
    try {
      final recent = await _localDataSource.getRecentPlayed(limit: limit);
      final withSongs = <RecentPlayed>[];

      for (final r in recent) {
        final song = await _localDataSource.getSongById(r.songId);
        withSongs.add(RecentPlayed(
          id: r.id,
          songId: r.songId,
          playedAt: r.playedAt,
          song: song?.toEntity(),
        ));
      }

      return Right(withSongs);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> scanAndSaveSongs() async {
    try {
      final existingPaths = await _localDataSource.getAllFilePaths();
      final scannedSongs = await _audioScanDataSource.scanAudioFiles();

      final newSongs = scannedSongs.where((s) => !existingPaths.contains(s.filePath)).toList();

      if (newSongs.isNotEmpty) {
        await _localDataSource.insertAllSongs(newSongs);
      }

      return Right(newSongs.length);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToRecentPlayed(Song song) async {
    try {
      if (song.id == null) {
        return const Left(DatabaseFailure('Song ID is required'));
      }
      await _localDataSource.addToRecentPlayed(song.id!);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Song>> updateSongMetadata(
    Song song, {
    String? title,
    String? artist,
    String? album,
    String? albumArtPath,
    String? artistImagePath,
    bool? isHidden,
  }) async {
    try {
      if (song.id == null) {
        return const Left(DatabaseFailure('Song ID is required'));
      }

      final updatedSong = SongModel.fromEntity(song.copyWith(
        title: title ?? song.title,
        artist: artist ?? song.artist,
        album: album ?? song.album,
        albumArtPath: albumArtPath ?? song.albumArtPath,
        artistImagePath: artistImagePath ?? song.artistImagePath,
        isHidden: isHidden ?? song.isHidden,
      ));

      await _localDataSource.updateSong(updatedSong);

      final fetched = await _localDataSource.getSongById(song.id!);
      if (fetched == null) {
        return const Left(DatabaseFailure('Failed to retrieve updated song'));
      }

      return Right(fetched.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
