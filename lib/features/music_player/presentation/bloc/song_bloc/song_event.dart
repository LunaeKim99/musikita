import 'package:equatable/equatable.dart';

sealed class SongEvent extends Equatable {
  const SongEvent();

  @override
  List<Object?> get props => [];
}

class LoadSongs extends SongEvent {
  const LoadSongs();
}

class SearchSongsEvent extends SongEvent {
  final String query;

  const SearchSongsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ScanSongsEvent extends SongEvent {
  const ScanSongsEvent();
}

class ClearSearch extends SongEvent {
  const ClearSearch();
}
