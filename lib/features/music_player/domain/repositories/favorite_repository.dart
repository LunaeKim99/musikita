import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

abstract class FavoriteRepository {
  Future<Either<Failure, List<Song>>> getFavoriteSongs();
  Future<Either<Failure, bool>> isFavorite(int songId);
  Future<Either<Failure, void>> toggleFavorite(int songId);
  Future<Either<Failure, void>> saveFavorite(int songId);
  Future<Either<Failure, void>> removeFavorite(int songId);
}
