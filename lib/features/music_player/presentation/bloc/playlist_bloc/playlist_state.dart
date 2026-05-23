import 'package:equatable/equatable.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

sealed class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

class PlaylistInitial extends PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class PlaylistsLoaded extends PlaylistState {
  final List<Playlist> playlists;

  const PlaylistsLoaded(this.playlists);

  int get count => playlists.length;

  @override
  List<Object?> get props => [playlists];
}

class PlaylistDetailLoaded extends PlaylistState {
  final Playlist playlist;
  final List<Song> songs;

  const PlaylistDetailLoaded({
    required this.playlist,
    required this.songs,
  });

  @override
  List<Object?> get props => [playlist, songs];
}

class PlaylistCreated extends PlaylistState {
  final Playlist playlist;

  const PlaylistCreated(this.playlist);

  @override
  List<Object?> get props => [playlist];
}

class PlaylistDeleted extends PlaylistState {
  final int playlistId;

  const PlaylistDeleted(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class PlaylistRenamed extends PlaylistState {
  final int playlistId;
  final String newName;

  const PlaylistRenamed({
    required this.playlistId,
    required this.newName,
  });

  @override
  List<Object?> get props => [playlistId, newName];
}

class SongAddedToPlaylist extends PlaylistState {
  final int playlistId;
  final int songId;

  const SongAddedToPlaylist({
    required this.playlistId,
    required this.songId,
  });

  @override
  List<Object?> get props => [playlistId, songId];
}

class SongRemovedFromPlaylist extends PlaylistState {
  final int playlistId;
  final int songId;

  const SongRemovedFromPlaylist({
    required this.playlistId,
    required this.songId,
  });

  @override
  List<Object?> get props => [playlistId, songId];
}

class AddToPlaylistDialogRequested extends PlaylistState {
  final Song song;
  final List<Playlist> playlists;

  const AddToPlaylistDialogRequested({
    required this.song,
    required this.playlists,
  });

  @override
  List<Object?> get props => [song, playlists];
}

class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object?> get props => [message];
}
