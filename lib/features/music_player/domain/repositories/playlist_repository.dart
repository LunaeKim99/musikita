import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

abstract class PlaylistRepository {
  Future<Either<Failure, List<Playlist>>> getPlaylists();
  Future<Either<Failure, Playlist>> createPlaylist(String name);
  Future<Either<Failure, void>> deletePlaylist(int id);
  Future<Either<Failure, Playlist>> renamePlaylist(int id, String newName);
  Future<Either<Failure, List<Song>>> getPlaylistSongs(int playlistId);
  Future<Either<Failure, void>> addSongToPlaylist(int playlistId, int songId);
  Future<Either<Failure, void>> removeSongFromPlaylist(int playlistId, int songId);
}
