import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/data/datasources/local_datasource.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final LocalDataSource _localDataSource;

  FavoriteRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Song>>> getFavoriteSongs() async {
    try {
      final songs = await _localDataSource.getFavoriteSongs();
      return Right(songs.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int songId) async {
    try {
      final isFav = await _localDataSource.isFavorite(songId);
      return Right(isFav);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(int songId) async {
    try {
      final isFav = await _localDataSource.isFavorite(songId);
      if (isFav) {
        await _localDataSource.removeFavorite(songId);
      } else {
        await _localDataSource.addFavorite(songId);
      }
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveFavorite(int songId) async {
    try {
      await _localDataSource.addFavorite(songId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(int songId) async {
    try {
      await _localDataSource.removeFavorite(songId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
