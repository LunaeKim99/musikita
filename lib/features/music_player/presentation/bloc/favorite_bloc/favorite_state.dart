import 'package:equatable/equatable.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

sealed class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoritesLoaded extends FavoriteState {
  final List<Song> songs;
  final Set<int> favoriteIds;

  const FavoritesLoaded(this.songs, this.favoriteIds);

  bool isFavorite(int songId) => favoriteIds.contains(songId);

  int get songCount => songs.length;

  FavoritesLoaded copyWith({
    List<Song>? songs,
    Set<int>? favoriteIds,
  }) {
    return FavoritesLoaded(
      songs ?? this.songs,
      favoriteIds ?? this.favoriteIds,
    );
  }

  @override
  List<Object?> get props => [songs, favoriteIds];
}

class SingleFavoriteChecked extends FavoriteState {
  final int songId;
  final bool isFavorite;

  const SingleFavoriteChecked({
    required this.songId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [songId, isFavorite];
}

class FavoriteToggled extends FavoriteState {
  final int songId;
  final bool isNowFavorite;

  const FavoriteToggled({
    required this.songId,
    required this.isNowFavorite,
  });

  @override
  List<Object?> get props => [songId, isNowFavorite];
}

class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError(this.message);

  @override
  List<Object?> get props => [message];
}
