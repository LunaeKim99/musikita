import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/song_repository.dart';

class SearchSongs {
  final SongRepository _repository;

  SearchSongs(this._repository);

  Future<Either<Failure, List<Song>>> call(String query) async {
    if (query.trim().isEmpty) return const Right([]);
    return _repository.searchSongs(query.trim());
  }
}
