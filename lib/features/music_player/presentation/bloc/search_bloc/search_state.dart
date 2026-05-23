import 'package:equatable/equatable.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchResultsLoaded extends SearchState {
  final String query;
  final List<Song> songs;
  final List<Song> artistResults;
  final List<Song> albumResults;

  const SearchResultsLoaded({
    required this.query,
    required this.songs,
    this.artistResults = const [],
    this.albumResults = const [],
  });

  int get totalResults => songs.length + artistResults.length + albumResults.length;

  @override
  List<Object?> get props => [query, songs, artistResults, albumResults];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
