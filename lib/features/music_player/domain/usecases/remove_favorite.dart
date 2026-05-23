import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/repositories/favorite_repository.dart';

class RemoveFavorite {
  final FavoriteRepository _repository;

  RemoveFavorite(this._repository);

  Future<Either<Failure, void>> call(int songId) async {
    return _repository.removeFavorite(songId);
  }
}
