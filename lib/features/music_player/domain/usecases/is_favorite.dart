import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/repositories/favorite_repository.dart';

class IsFavorite {
  final FavoriteRepository _repository;

  IsFavorite(this._repository);

  Future<Either<Failure, bool>> call(int songId) async {
    return _repository.isFavorite(songId);
  }
}
