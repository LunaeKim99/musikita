import 'package:bloc/bloc.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/favorite_repository.dart';
import 'package:musikita/features/music_player/domain/usecases/is_favorite.dart';
import 'package:musikita/features/music_player/domain/usecases/remove_favorite.dart';
import 'package:musikita/features/music_player/domain/usecases/save_favorite.dart';
import 'package:musikita/features/music_player/domain/usecases/toggle_favorite.dart';
import 'favorite_event.dart' as ev;
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<ev.FavoriteEvent, FavoriteState> {
  final FavoriteRepository _favoriteRepository;
  final ToggleFavorite _toggleFavorite;
  final SaveFavorite _saveFavorite;
  final RemoveFavorite _removeFavorite;
  final IsFavorite _isFavorite;

  List<Song> _cachedSongs = [];
  Set<int> _cachedIds = {};

  FavoriteBloc({
    required FavoriteRepository favoriteRepository,
    required ToggleFavorite toggleFavorite,
    required SaveFavorite saveFavorite,
    required RemoveFavorite removeFavorite,
    required IsFavorite isFavorite,
  })  : _favoriteRepository = favoriteRepository,
        _toggleFavorite = toggleFavorite,
        _saveFavorite = saveFavorite,
        _removeFavorite = removeFavorite,
        _isFavorite = isFavorite,
        super(FavoriteInitial()) {
    on<ev.LoadFavorites>(_onLoadFavorites);
    on<ev.ToggleFavorite>(_onToggleFavorite);
    on<ev.AddFavorite>(_onAddFavorite);
    on<ev.RemoveFavorite>(_onRemoveFavorite);
    on<ev.CheckFavorite>(_onCheckFavorite);
  }

  Future<void> _onLoadFavorites(ev.LoadFavorites event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoading());
    final result = await _favoriteRepository.getFavoriteSongs();
    result.fold(
      (failure) => emit(FavoriteError(failure.message)),
      (songs) {
        _cachedSongs = songs;
        _cachedIds = songs.map((s) => s.id).whereType<int>().toSet();
        emit(FavoritesLoaded(songs, _cachedIds));
      },
    );
  }

  Future<void> _onToggleFavorite(ev.ToggleFavorite event, Emitter<FavoriteState> emit) async {
    final songId = event.songId;
    final currentState = state;

    if (currentState is FavoritesLoaded) {
      final isCurrentlyFavorite = currentState.isFavorite(songId);
      final result = await _toggleFavorite(songId);

      result.fold(
        (failure) => emit(FavoriteError(failure.message)),
        (_) async {
          final newIsFavorite = !isCurrentlyFavorite;

          final newIds = Set<int>.from(_cachedIds);
          if (newIsFavorite) {
            newIds.add(songId);
          } else {
            newIds.remove(songId);
          }
          _cachedIds = newIds;

          if (newIsFavorite) {
            final reloadResult = await _favoriteRepository.getFavoriteSongs();
            reloadResult.fold(
              (failure) => emit(FavoriteError(failure.message)),
              (songs) {
                _cachedSongs = songs;
                emit(FavoritesLoaded(songs, newIds));
              },
            );
          } else {
            final newSongs = _cachedSongs.where((s) => s.id != songId).toList();
            _cachedSongs = newSongs;
            emit(FavoritesLoaded(newSongs, newIds));
          }

          emit(FavoriteToggled(
            songId: songId,
            isNowFavorite: newIsFavorite,
          ));
        },
      );
    } else {
      final result = await _toggleFavorite(songId);
      result.fold(
        (failure) => emit(FavoriteError(failure.message)),
        (isNowFavorite) {
          emit(FavoriteToggled(
            songId: songId,
            isNowFavorite: isNowFavorite,
          ));
        },
      );
    }
  }

  Future<void> _onAddFavorite(ev.AddFavorite event, Emitter<FavoriteState> emit) async {
    final result = await _saveFavorite(event.songId);
    result.fold(
      (failure) => emit(FavoriteError(failure.message)),
      (_) {
        if (state is FavoritesLoaded) {
          final currentState = state as FavoritesLoaded;
          final newIds = Set<int>.from(currentState.favoriteIds)..add(event.songId);
          emit(currentState.copyWith(favoriteIds: newIds));
        }
      },
    );
  }

  Future<void> _onRemoveFavorite(ev.RemoveFavorite event, Emitter<FavoriteState> emit) async {
    final result = await _removeFavorite(event.songId);
    result.fold(
      (failure) => emit(FavoriteError(failure.message)),
      (_) {
        if (state is FavoritesLoaded) {
          final currentState = state as FavoritesLoaded;
          final newIds = Set<int>.from(currentState.favoriteIds)..remove(event.songId);
          final newSongs = currentState.songs.where((s) => s.id != event.songId).toList();
          emit(currentState.copyWith(songs: newSongs, favoriteIds: newIds));
        }
      },
    );
  }

  Future<void> _onCheckFavorite(ev.CheckFavorite event, Emitter<FavoriteState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      emit(SingleFavoriteChecked(
        songId: event.songId,
        isFavorite: currentState.isFavorite(event.songId),
      ));
      return;
    }

    final result = await _isFavorite(event.songId);
    result.fold(
      (failure) => emit(FavoriteError(failure.message)),
      (isFav) => emit(SingleFavoriteChecked(
            songId: event.songId,
            isFavorite: isFav,
          )),
    );
  }
}
