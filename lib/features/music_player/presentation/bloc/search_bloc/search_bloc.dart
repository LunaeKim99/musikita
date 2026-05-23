import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/usecases/search_songs.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchSongs _searchSongs;

  SearchBloc({
    required SearchSongs searchSongs,
  })  : _searchSongs = searchSongs,
        super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    if (query.length < 2) {
      return;
    }

    emit(SearchLoading());

    final result = await _searchSongs(query);
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (songs) {
        if (songs.isEmpty) {
          emit(SearchEmpty(query));
        } else {
          final grouped = _groupResults(songs, query);
          emit(SearchResultsLoaded(
            query: query,
            songs: grouped['songs'] ?? <Song>[],
            artistResults: grouped['artists'] ?? <Song>[],
            albumResults: grouped['albums'] ?? <Song>[],
          ));
        }
      },
    );
  }

  Future<void> _onSearchSubmitted(SearchSubmitted event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    final result = await _searchSongs(query);
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (songs) {
        if (songs.isEmpty) {
          emit(SearchEmpty(query));
        } else {
          final grouped = _groupResults(songs, query);
          emit(SearchResultsLoaded(
            query: query,
            songs: grouped['songs'] ?? <Song>[],
            artistResults: grouped['artists'] ?? <Song>[],
            albumResults: grouped['albums'] ?? <Song>[],
          ));
        }
      },
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }

  Map<String, List<Song>> _groupResults(List<Song> songs, String query) {
    final queryLower = query.toLowerCase();
    final titleMatches = <Song>[];
    final artistMatches = <Song>[];
    final albumMatches = <Song>[];

    for (final song in songs) {
      final titleMatch = song.title.toLowerCase().contains(queryLower);
      final artistMatch = song.artist.toLowerCase().contains(queryLower);
      final albumMatch = song.album.toLowerCase().contains(queryLower);

      if (titleMatch) {
        titleMatches.add(song);
      } else if (artistMatch) {
        artistMatches.add(song);
      } else if (albumMatch) {
        albumMatches.add(song);
      } else {
        titleMatches.add(song);
      }
    }

    final artistGroups = groupBy(artistMatches, (Song s) => s.artist.toLowerCase());
    final albumGroups = groupBy(albumMatches, (Song s) => s.album.toLowerCase());

    final uniqueArtists = <Song>[];
    for (final group in artistGroups.values) {
      if (group.isNotEmpty) {
        uniqueArtists.add(group.first);
      }
    }

    final uniqueAlbums = <Song>[];
    for (final group in albumGroups.values) {
      if (group.isNotEmpty) {
        uniqueAlbums.add(group.first);
      }
    }

    return {
      'songs': titleMatches,
      'artists': uniqueArtists,
      'albums': uniqueAlbums,
    };
  }
}
