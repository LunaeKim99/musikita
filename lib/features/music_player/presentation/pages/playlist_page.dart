import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/widgets/empty_state_widget.dart';
import 'package:musikita/features/music_player/presentation/widgets/playlist_tile.dart';
import 'package:musikita/app.dart' as app show mainScaffoldKey;

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  void _loadPlaylists() {
    context.read<PlaylistBloc>().add(const LoadPlaylists());
  }

  void _createPlaylist() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Playlist name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  context.read<PlaylistBloc>().add(CreatePlaylist(name));
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showPlaylistMenu(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play Playlist'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<PlaylistBloc>().add(LoadPlaylistSongs(playlist.id!));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(sheetContext);
                _renamePlaylist(context, playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context, playlist);
              },
            ),
          ],
        );
      },
    );
  }

  void _renamePlaylist(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController(text: playlist.name);
        return AlertDialog(
          title: const Text('Rename Playlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'New name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  context.read<PlaylistBloc>().add(RenamePlaylist(
                        playlistId: playlist.id!,
                        newName: name,
                      ));
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Playlist'),
          content: Text('Are you sure you want to delete "${playlist.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<PlaylistBloc>().add(DeletePlaylist(playlist.id!));
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => app.mainScaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Playlists'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        tooltip: 'Create Playlist',
        child: const Icon(Icons.add),
      ),
      body: BlocListener<PlaylistBloc, PlaylistState>(
        listener: (context, state) {
          if (state is PlaylistDetailLoaded) {
            if (state.songs.isNotEmpty) {
              context.read<PlayerBloc>().add(PlayFromQueue(
                    songs: state.songs,
                    initialIndex: 0,
                  ));
            }
          }
          if (state is PlaylistCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Created "${state.playlist.name}"')),
            );
          }
          if (state is PlaylistDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Playlist deleted')),
            );
          }
        },
        child: BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: (context, state) {
            if (state is PlaylistLoading || state is PlaylistInitial) {
              return const LoadingStateWidget();
            }

            if (state is PlaylistError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: _loadPlaylists,
              );
            }

            if (state is PlaylistsLoaded) {
              if (state.playlists.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.playlist_play,
                  title: 'No playlists yet',
                  subtitle: 'Create your first playlist to get started',
                  action: ElevatedButton.icon(
                    onPressed: _createPlaylist,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Playlist'),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _loadPlaylists();
                },
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 100,
                  ),
                  itemCount: state.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = state.playlists[index];
                    return PlaylistTile(
                      playlist: playlist,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/playlist-detail',
                          arguments: playlist,
                        );
                      },
                      onLongPress: () => _showPlaylistMenu(context, playlist),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
