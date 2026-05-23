import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/widgets/empty_state_widget.dart';
import 'package:musikita/features/music_player/presentation/widgets/song_tile.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({
    super.key,
    required this.playlist,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  List<Song> _songs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  void _loadSongs() {
    context.read<PlaylistBloc>().add(LoadPlaylistSongs(widget.playlist.id!));
  }

  void _playAll() {
    if (_songs.isNotEmpty) {
      context.read<PlayerBloc>().add(PlayFromQueue(
            songs: _songs,
            initialIndex: 0,
          ));
    }
  }

  void _shufflePlay() {
    if (_songs.isNotEmpty) {
      final shuffled = List<Song>.from(_songs)..shuffle();
      context.read<PlayerBloc>().add(PlayFromQueue(
            songs: shuffled,
            initialIndex: 0,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaylistBloc, PlaylistState>(
      listener: (context, state) {
        if (state is PlaylistDetailLoaded) {
          setState(() {
            _songs = state.songs;
          });
        }
        if (state is SongRemovedFromPlaylist) {
          if (state.playlistId == widget.playlist.id) {
            _loadSongs();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.playlist.name),
        ),
        body: BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: (context, state) {
            if (state is PlaylistLoading) {
              return const LoadingStateWidget();
            }

            if (state is PlaylistError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: _loadSongs,
              );
            }

            var songs = _songs;
            if (state is PlaylistDetailLoaded) {
              songs = state.songs;
            }

            if (songs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.playlist_play,
                title: 'No songs in playlist',
                subtitle: 'Add songs to get started',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadSongs();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(songs),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];
                        return SongTile(
                          song: song,
                          index: index,
                          queueContext: songs,
                          onTap: () {
                            context.read<PlayerBloc>().add(PlayFromQueue(
                                  songs: songs,
                                  initialIndex: index,
                                ));
                          },
                        );
                      },
                      childCount: songs.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(List<Song> songs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.playlist_play,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.playlist.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${songs.length} songs',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: songs.isNotEmpty ? _playAll : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: songs.isNotEmpty ? _shufflePlay : null,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Shuffle'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }
}
