import 'package:bloc/bloc.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/usecases/get_songs.dart';
import 'package:musikita/features/music_player/domain/usecases/scan_songs.dart';
import 'package:musikita/features/music_player/domain/usecases/search_songs.dart';
import 'song_event.dart';
import 'song_state.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final GetSongs _getSongs;
  final SearchSongs _searchSongs;
  final ScanSongs _scanSongs;

  List<Song> _cachedSongs = [];

  SongBloc({
    required this._getSongs,
    required this._searchSongs,
    required this._scanSongs,
  }) : super(SongInitial()) {
    on<LoadSongs>(_onLoadSongs);
    on<SearchSongsEvent>(_onSearchSongs);
    on<ScanSongsEvent>(_onScanSongs);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadSongs(LoadSongs event, Emitter<SongState> emit) async {
    emit(SongLoading());
    final result = await _getSongs(showHidden: event.showHidden);
    result.fold(
      (failure) => emit(SongError(failure.message)),
      (songs) {
        _cachedSongs = songs;
        emit(SongsLoaded(songs));
      },
    );
  }

  Future<void> _onSearchSongs(SearchSongsEvent event, Emitter<SongState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      if (_cachedSongs.isNotEmpty) {
        emit(SongsLoaded(_cachedSongs));
      } else {
        emit(SongInitial());
      }
      return;
    }

    final result = await _searchSongs(query, showHidden: event.showHidden);
    result.fold(
      (failure) => emit(SongError(failure.message)),
      (songs) => emit(SearchResultsLoaded(songs, query)),
    );
  }

  Future<void> _onScanSongs(ScanSongsEvent event, Emitter<SongState> emit) async {
    emit(ScanningInProgress());

    final result = await _scanSongs(paths: event.paths);

    if (result.isLeft()) {
      result.fold(
        (failure) => emit(SongError(failure.message)),
        (_) => null,
      );
      return;
    }

    final newSongsCount = result.getOrElse(() => 0);
    final reloadResult = await _getSongs(showHidden: event.showHidden);
    reloadResult.fold(
      (failure) => emit(SongError(failure.message)),
      (songs) {
        _cachedSongs = songs;
        emit(ScanComplete(
          newSongsCount: newSongsCount,
          updatedSongs: songs,
        ));
      },
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<SongState> emit) {
    if (_cachedSongs.isNotEmpty) {
      emit(SongsLoaded(_cachedSongs));
    } else {
      emit(SongInitial());
    }
  }
}
