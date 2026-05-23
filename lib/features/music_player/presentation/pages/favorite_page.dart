import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/widgets/empty_state_widget.dart';
import 'package:musikita/features/music_player/presentation/widgets/song_tile.dart';
import 'package:musikita/app.dart' as app show mainScaffoldKey;

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    context.read<FavoriteBloc>().add(const LoadFavorites());
  }

  void _playAll(List<Song> songs) {
    if (songs.isNotEmpty) {
      context.read<PlayerBloc>().add(PlayFromQueue(
            songs: songs,
            initialIndex: 0,
          ));
    }
  }

  void _shufflePlay(List<Song> songs) {
    if (songs.isNotEmpty) {
      final shuffled = List<Song>.from(songs)..shuffle();
      context.read<PlayerBloc>().add(PlayFromQueue(
            songs: shuffled,
            initialIndex: 0,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => app.mainScaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Favorites'),
        actions: [
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              if (state is FavoritesLoaded && state.songs.isNotEmpty) {
                return PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'play',
                      child: Text('Play All'),
                    ),
                    const PopupMenuItem(
                      value: 'shuffle',
                      child: Text('Shuffle Play'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'play') {
                      _playAll(state.songs);
                    } else if (value == 'shuffle') {
                      _shufflePlay(state.songs);
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading || state is FavoriteInitial) {
            return const LoadingStateWidget();
          }

          if (state is FavoriteError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: _loadFavorites,
            );
          }

          if (state is FavoritesLoaded) {
            if (state.songs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.favorite_border,
                title: 'No favorites yet',
                subtitle: 'Tap the heart icon on any song to add it here',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadFavorites();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(state.songs),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = state.songs[index];
                        return SongTile(
                          song: song,
                          index: index,
                          queueContext: state.songs,
                          onTap: () {
                            context.read<PlayerBloc>().add(PlayFromQueue(
                                  songs: state.songs,
                                  initialIndex: index,
                                ));
                          },
                        );
                      },
                      childCount: state.songs.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(List<Song> songs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${songs.length} songs',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: songs.isNotEmpty ? () => _playAll(songs) : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: songs.isNotEmpty ? () => _shufflePlay(songs) : null,
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
