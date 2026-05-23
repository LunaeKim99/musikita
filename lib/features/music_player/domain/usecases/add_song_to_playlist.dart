import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/repositories/playlist_repository.dart';

class AddSongToPlaylist {
  final PlaylistRepository _repository;

  AddSongToPlaylist(this._repository);

  Future<Either<Failure, void>> call({
    required int playlistId,
    required int songId,
  }) async {
    return _repository.addSongToPlaylist(playlistId, songId);
  }
}
