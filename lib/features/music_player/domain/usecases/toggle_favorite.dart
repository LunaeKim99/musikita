import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/repositories/favorite_repository.dart';

class ToggleFavorite {
  final FavoriteRepository _repository;

  ToggleFavorite(this._repository);

  Future<Either<Failure, bool>> call(int songId) async {
    final isFavResult = await _repository.isFavorite(songId);
    return isFavResult.fold(
      (failure) => Left(failure),
      (isFav) async {
        final toggleResult = await _repository.toggleFavorite(songId);
        return toggleResult.fold(
          Left.new,
          (_) => Right(!isFav),
        );
      },
    );
  }
}
