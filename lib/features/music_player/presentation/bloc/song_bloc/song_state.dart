import 'package:equatable/equatable.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

sealed class SongState extends Equatable {
  const SongState();

  @override
  List<Object?> get props => [];
}

class SongInitial extends SongState {}

class SongLoading extends SongState {}

class SongsLoaded extends SongState {
  final List<Song> songs;

  const SongsLoaded(this.songs);

  @override
  List<Object?> get props => [songs];
}

class SearchResultsLoaded extends SongState {
  final List<Song> results;
  final String query;

  const SearchResultsLoaded(this.results, this.query);

  @override
  List<Object?> get props => [results, query];
}

class ScanningInProgress extends SongState {
  final int scannedCount;
  final int totalFound;

  const ScanningInProgress({
    this.scannedCount = 0,
    this.totalFound = 0,
  });

  @override
  List<Object?> get props => [scannedCount, totalFound];
}

class ScanComplete extends SongState {
  final int newSongsCount;
  final List<Song> updatedSongs;

  const ScanComplete({
    required this.newSongsCount,
    required this.updatedSongs,
  });

  @override
  List<Object?> get props => [newSongsCount, updatedSongs];
}

class SongError extends SongState {
  final String message;

  const SongError(this.message);

  @override
  List<Object?> get props => [message];
}
