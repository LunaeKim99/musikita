import 'package:equatable/equatable.dart';

sealed class SongEvent extends Equatable {
  const SongEvent();

  @override
  List<Object?> get props => [];
}

class LoadSongs extends SongEvent {
  final bool showHidden;

  const LoadSongs({this.showHidden = false});

  @override
  List<Object?> get props => [showHidden];
}

class SearchSongsEvent extends SongEvent {
  final String query;
  final bool showHidden;

  const SearchSongsEvent(this.query, {this.showHidden = false});

  @override
  List<Object?> get props => [query, showHidden];
}

class ScanSongsEvent extends SongEvent {
  final bool showHidden;
  final List<String>? paths;

  const ScanSongsEvent({this.showHidden = false, this.paths});

  @override
  List<Object?> get props => [showHidden, paths];
}

class ClearSearch extends SongEvent {
  const ClearSearch();
}
