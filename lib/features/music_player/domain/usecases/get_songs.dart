import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/song_repository.dart';

class GetSongs {
  final SongRepository _repository;

  GetSongs(this._repository);

  Future<Either<Failure, List<Song>>> call({bool showHidden = false}) async {
    return _repository.getSongs(showHidden: showHidden);
  }
}
