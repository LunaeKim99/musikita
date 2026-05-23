import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/repositories/playlist_repository.dart';

class CreatePlaylist {
  final PlaylistRepository _repository;

  CreatePlaylist(this._repository);

  Future<Either<Failure, Playlist>> call(String name) async {
    if (name.trim().isEmpty) {
      return const Left(DatabaseFailure('Nama playlist tidak boleh kosong'));
    }
    return _repository.createPlaylist(name.trim());
  }
}
