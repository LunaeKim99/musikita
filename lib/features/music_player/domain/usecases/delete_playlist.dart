import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/repositories/playlist_repository.dart';

class DeletePlaylist {
  final PlaylistRepository _repository;

  DeletePlaylist(this._repository);

  Future<Either<Failure, void>> call(int id) async {
    return _repository.deletePlaylist(id);
  }
}
