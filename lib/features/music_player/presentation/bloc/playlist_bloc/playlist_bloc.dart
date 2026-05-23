import 'package:bloc/bloc.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/playlist_repository.dart';
import 'package:musikita/features/music_player/domain/usecases/add_song_to_playlist.dart';
import 'package:musikita/features/music_player/domain/usecases/create_playlist.dart';
import 'package:musikita/features/music_player/domain/usecases/delete_playlist.dart';
import 'package:musikita/features/music_player/domain/usecases/get_playlists.dart';
import 'playlist_event.dart' as ev;
import 'playlist_state.dart';

class PlaylistBloc extends Bloc<ev.PlaylistEvent, PlaylistState> {
  final GetPlaylists _getPlaylistsUC;
  final CreatePlaylist _createPlaylistUC;
  final DeletePlaylist _deletePlaylistUC;
  final AddSongToPlaylist _addSongToPlaylistUC;
  final PlaylistRepository _playlistRepository;

  List<Playlist> _cachedPlaylists = [];
  Playlist? _currentDetailPlaylist;

  PlaylistBloc({
    required GetPlaylists getPlaylists,
    required CreatePlaylist createPlaylist,
    required DeletePlaylist deletePlaylist,
    required AddSongToPlaylist addSongToPlaylist,
    required PlaylistRepository playlistRepository,
  })  : _getPlaylistsUC = getPlaylists,
        _createPlaylistUC = createPlaylist,
        _deletePlaylistUC = deletePlaylist,
        _addSongToPlaylistUC = addSongToPlaylist,
        _playlistRepository = playlistRepository,
        super(PlaylistInitial()) {
    on<ev.LoadPlaylists>(_onLoadPlaylists);
    on<ev.CreatePlaylist>(_onCreatePlaylist);
    on<ev.DeletePlaylist>(_onDeletePlaylist);
    on<ev.RenamePlaylist>(_onRenamePlaylist);
    on<ev.LoadPlaylistSongs>(_onLoadPlaylistSongs);
    on<ev.AddSongToPlaylist>(_onAddSongToPlaylist);
    on<ev.RemoveSongFromPlaylist>(_onRemoveSongFromPlaylist);
    on<ev.ShowAddToPlaylistDialog>(_onShowAddToPlaylistDialog);
  }

  Future<void> _onLoadPlaylists(ev.LoadPlaylists event, Emitter<PlaylistState> emit) async {
    emit(PlaylistLoading());
    final result = await _getPlaylistsUC();
    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (playlists) {
        _cachedPlaylists = playlists;
        emit(PlaylistsLoaded(playlists));
      },
    );
  }

  Future<void> _onCreatePlaylist(ev.CreatePlaylist event, Emitter<PlaylistState> emit) async {
    final result = await _createPlaylistUC(event.name);
    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (playlist) {
        final newList = List<Playlist>.from(_cachedPlaylists)..add(playlist);
        _cachedPlaylists = newList;
        emit(PlaylistCreated(playlist));
        emit(PlaylistsLoaded(newList));
      },
    );
  }

  Future<void> _onDeletePlaylist(ev.DeletePlaylist event, Emitter<PlaylistState> emit) async {
    final result = await _deletePlaylistUC(event.playlistId);
    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (_) {
        final newList = _cachedPlaylists.where((p) => p.id != event.playlistId).toList();
        _cachedPlaylists = newList;
        emit(PlaylistDeleted(event.playlistId));
        emit(PlaylistsLoaded(newList));
      },
    );
  }

  Future<void> _onRenamePlaylist(ev.RenamePlaylist event, Emitter<PlaylistState> emit) async {
    final result = await _playlistRepository.renamePlaylist(event.playlistId, event.newName);
    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (playlist) {
        final newList = _cachedPlaylists.map((p) {
          if (p.id == event.playlistId) {
            return playlist;
          }
          return p;
        }).toList();
        _cachedPlaylists = newList;
        emit(PlaylistRenamed(
          playlistId: event.playlistId,
          newName: event.newName,
        ));
        emit(PlaylistsLoaded(newList));
      },
    );
  }

  Future<void> _onLoadPlaylistSongs(ev.LoadPlaylistSongs event, Emitter<PlaylistState> emit) async {
    emit(PlaylistLoading());

    final playlist = _cachedPlaylists.firstWhere(
      (p) => p.id == event.playlistId,
      orElse: () => Playlist(id: event.playlistId, name: 'Unknown'),
    );

    final result = await _playlistRepository.getPlaylistSongs(event.playlistId);
    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (songs) {
        _currentDetailPlaylist = playlist;
        emit(PlaylistDetailLoaded(
          playlist: playlist,
          songs: songs,
        ));
      },
    );
  }

  Future<void> _onAddSongToPlaylist(ev.AddSongToPlaylist event, Emitter<PlaylistState> emit) async {
    final result = await _addSongToPlaylistUC(
      playlistId: event.playlistId,
      songId: event.songId,
    );
    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (_) => emit(SongAddedToPlaylist(
            playlistId: event.playlistId,
            songId: event.songId,
          )),
    );
  }

  Future<void> _onRemoveSongFromPlaylist(ev.RemoveSongFromPlaylist event, Emitter<PlaylistState> emit) async {
    final result = await _playlistRepository.removeSongFromPlaylist(event.playlistId, event.songId);
    result.fold(
      (failure) => emit(PlaylistError(failure.message)),
      (_) async {
        emit(SongRemovedFromPlaylist(
          playlistId: event.playlistId,
          songId: event.songId,
        ));

        if (_currentDetailPlaylist?.id == event.playlistId) {
          final reloadResult = await _playlistRepository.getPlaylistSongs(event.playlistId);
          reloadResult.fold(
            (f) => null,
            (songs) {
              emit(PlaylistDetailLoaded(
                playlist: _currentDetailPlaylist!,
                songs: songs,
              ));
            },
          );
        }
      },
    );
  }

  Future<void> _onShowAddToPlaylistDialog(ev.ShowAddToPlaylistDialog event, Emitter<PlaylistState> emit) async {
    if (_cachedPlaylists.isEmpty) {
      final result = await _getPlaylistsUC();
      result.fold(
        (failure) => emit(PlaylistError(failure.message)),
        (playlists) {
          _cachedPlaylists = playlists;
          emit(AddToPlaylistDialogRequested(
            song: event.song,
            playlists: playlists,
          ));
        },
      );
    } else {
      emit(AddToPlaylistDialogRequested(
        song: event.song,
        playlists: _cachedPlaylists,
      ));
    }
  }
}
