import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/repositories/playlist_repository.dart';

class GetPlaylists {
  final PlaylistRepository _repository;

  GetPlaylists(this._repository);

  Future<Either<Failure, List<Playlist>>> call() async {
    return _repository.getPlaylists();
  }
}
