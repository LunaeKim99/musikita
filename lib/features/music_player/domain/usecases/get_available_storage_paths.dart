import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/repositories/song_repository.dart';

class GetAvailableStoragePaths {
  final SongRepository _repository;

  GetAvailableStoragePaths(this._repository);

  Future<Either<Failure, List<String>>> call() async {
    return _repository.getAvailableStoragePaths();
  }
}
