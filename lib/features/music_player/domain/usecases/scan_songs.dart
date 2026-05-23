import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/repositories/song_repository.dart';

class ScanSongs {
  final SongRepository _repository;

  ScanSongs(this._repository);

  Future<Either<Failure, int>> call() async {
    return _repository.scanAndSaveSongs();
  }
}
