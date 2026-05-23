import 'package:equatable/equatable.dart';

sealed class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {
  const LoadFavorites();
}

class ToggleFavorite extends FavoriteEvent {
  final int songId;

  const ToggleFavorite(this.songId);

  @override
  List<Object?> get props => [songId];
}

class AddFavorite extends FavoriteEvent {
  final int songId;

  const AddFavorite(this.songId);

  @override
  List<Object?> get props => [songId];
}

class RemoveFavorite extends FavoriteEvent {
  final int songId;

  const RemoveFavorite(this.songId);

  @override
  List<Object?> get props => [songId];
}

class CheckFavorite extends FavoriteEvent {
  final int songId;

  const CheckFavorite(this.songId);

  @override
  List<Object?> get props => [songId];
}
