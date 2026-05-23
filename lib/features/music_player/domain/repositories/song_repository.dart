import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/recent_played.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

abstract class SongRepository {
  Future<Either<Failure, List<Song>>> getSongs({bool showHidden = false});
  Future<Either<Failure, List<Song>>> searchSongs(String query, {bool showHidden = false});
  Future<Either<Failure, List<RecentPlayed>>> getRecentPlayed({int limit = 50});
  Future<Either<Failure, int>> scanAndSaveSongs();
  Future<Either<Failure, void>> addToRecentPlayed(Song song);
  Future<Either<Failure, Song>> updateSongMetadata(
    Song song, {
    String? title,
    String? artist,
    String? album,
    String? albumArtPath,
    String? artistImagePath,
    bool? isHidden,
  });
}
