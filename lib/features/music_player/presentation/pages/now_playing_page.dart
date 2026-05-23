import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/core/utils/extensions.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_state.dart';
import 'package:musikita/features/music_player/presentation/widgets/lrc_lyrics_widget.dart';
import 'package:musikita/features/music_player/presentation/widgets/player_controls.dart';
import 'package:musikita/features/music_player/presentation/widgets/seek_bar.dart';
import 'package:musikita/features/music_player/utils/lrc_parser.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  bool _showLyrics = false;
  List<LyricLine> _lyrics = [];

  @override
  void initState() {
    super.initState();
    _checkFavorites();
  }

  void _checkFavorites() {
    context.read<FavoriteBloc>().add(const LoadFavorites());
  }

  void _loadLyrics(Song? song) {
    if (song == null) {
      setState(() {
        _lyrics = [];
      });
      return;
    }

    final lrcPath = song.filePath.replaceAll(
      '.${song.filePath.split('.').last}',
      '.lrc',
    );

    final lrcFile = File(lrcPath);
    lrcFile.exists().then((exists) {
      if (exists) {
        LrcParser.parseFile(lrcPath).then((lyrics) {
          setState(() {
            _lyrics = lyrics;
          });
        });
      } else {
        setState(() {
          _lyrics = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        if (state is! PlayerReady || !state.hasCurrentSong) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
            ),
            body: const Center(
              child: Text('No song playing'),
            ),
          );
        }

        final playerState = state;
        final song = playerState.currentSong!;

        if (_lyrics.isEmpty) {
          _loadLyrics(song);
        }

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Now Playing'),
            actions: [
              IconButton(
                icon: Icon(
                  _showLyrics ? Icons.lyrics : Icons.lyrics_outlined,
                  color: _showLyrics
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () {
                  setState(() => _showLyrics = !_showLyrics);
                },
                tooltip: 'Lyrics',
              ),
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'queue',
                    child: Text('Show Queue'),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Text('Share'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'queue') {
                    _showQueueDialog(context, playerState.queue);
                  }
                },
              ),
            ],
          ),
          body: _showLyrics
              ? _buildLyricsView(playerState)
              : _buildAlbumArtView(playerState, song),
        );
      },
    );
  }

  Widget _buildAlbumArtView(PlayerReady state, Song song) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(song.albumArtPath ?? ''),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.music_note,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.album,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, favState) {
                  bool isFavorite = false;
                  if (favState is FavoritesLoaded && song.id != null) {
                    isFavorite = favState.isFavorite(song.id!);
                  }

                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      size: 32,
                    ),
                    onPressed: () {
                      if (song.id != null) {
                        context.read<FavoriteBloc>().add(ToggleFavorite(song.id!));
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SeekBar(
            duration: state.duration,
            position: state.position,
            onChanged: (position) {
              context.read<PlayerBloc>().add(SeekToPosition(position));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: PlayerControls(
            state: state,
            onEvent: (event) => context.read<PlayerBloc>().add(event),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  Widget _buildLyricsView(PlayerReady state) {
    return Column(
      children: [
        SeekBar(
          duration: state.duration,
          position: state.position,
          onChanged: (position) {
            context.read<PlayerBloc>().add(SeekToPosition(position));
          },
        ),
        Expanded(
          child: LrcLyricsWidget(
            lyrics: _lyrics,
            currentPosition: state.position,
            onSeek: (position) {
              context.read<PlayerBloc>().add(SeekToPosition(position));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: PlayerControls(
            state: state,
            onEvent: (event) => context.read<PlayerBloc>().add(event),
          ),
        ),
      ],
    );
  }

  void _showQueueDialog(BuildContext context, List<Song> queue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                ListTile(
                  title: Text(
                    'Up Next',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final song = queue[index];
                      return ListTile(
                        leading: Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        title: Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Text(
                          Duration(milliseconds: song.duration).formatMmSs(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () {
                          context.read<PlayerBloc>().add(PlayFromQueue(
                                songs: queue,
                                initialIndex: index,
                              ));
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
