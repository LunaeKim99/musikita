import 'package:equatable/equatable.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

sealed class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlaylists extends PlaylistEvent {
  const LoadPlaylists();
}

class CreatePlaylist extends PlaylistEvent {
  final String name;

  const CreatePlaylist(this.name);

  @override
  List<Object?> get props => [name];
}

class DeletePlaylist extends PlaylistEvent {
  final int playlistId;

  const DeletePlaylist(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class RenamePlaylist extends PlaylistEvent {
  final int playlistId;
  final String newName;

  const RenamePlaylist({
    required this.playlistId,
    required this.newName,
  });

  @override
  List<Object?> get props => [playlistId, newName];
}

class LoadPlaylistSongs extends PlaylistEvent {
  final int playlistId;

  const LoadPlaylistSongs(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class AddSongToPlaylist extends PlaylistEvent {
  final int playlistId;
  final int songId;

  const AddSongToPlaylist({
    required this.playlistId,
    required this.songId,
  });

  @override
  List<Object?> get props => [playlistId, songId];
}

class RemoveSongFromPlaylist extends PlaylistEvent {
  final int playlistId;
  final int songId;

  const RemoveSongFromPlaylist({
    required this.playlistId,
    required this.songId,
  });

  @override
  List<Object?> get props => [playlistId, songId];
}

class PlayPlaylist extends PlaylistEvent {
  final Playlist playlist;
  final int startIndex;

  const PlayPlaylist({
    required this.playlist,
    this.startIndex = 0,
  });

  @override
  List<Object?> get props => [playlist, startIndex];
}

class ShowAddToPlaylistDialog extends PlaylistEvent {
  final Song song;

  const ShowAddToPlaylistDialog(this.song);

  @override
  List<Object?> get props => [song];
}
