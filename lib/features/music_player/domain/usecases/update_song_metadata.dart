import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/song_repository.dart';

class UpdateSongMetadata {
  final SongRepository _repository;

  UpdateSongMetadata(this._repository);

  Future<Either<Failure, Song>> call({
    required Song song,
    String? title,
    String? artist,
    String? album,
    String? albumArtPath,
  }) async {
    return _repository.updateSongMetadata(
      song,
      title: title,
      artist: artist,
      album: album,
      albumArtPath: albumArtPath,
    );
  }
}
