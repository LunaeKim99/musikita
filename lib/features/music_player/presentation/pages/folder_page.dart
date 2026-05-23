import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/features/music_player/domain/entities/folder.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/presentation/bloc/folder_bloc/folder_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/folder_bloc/folder_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/folder_bloc/folder_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/widgets/empty_state_widget.dart';
import 'package:musikita/features/music_player/presentation/widgets/folder_tile.dart';
import 'package:musikita/features/music_player/presentation/widgets/song_tile.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() {
    context.read<FolderBloc>().add(const LoadRootFolders());
  }

  void _playAll(List<Song> songs) {
    if (songs.isNotEmpty) {
      context.read<PlayerBloc>().add(PlayFromQueue(
            songs: songs,
            initialIndex: 0,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<FolderBloc, FolderState>(
          builder: (context, state) {
            if (state is FoldersLoaded) {
              return Text(state.currentFolder.name);
            }
            return const Text('Folders');
          },
        ),
        leading: BlocBuilder<FolderBloc, FolderState>(
          builder: (context, state) {
            if (state is FoldersLoaded && state.canNavigateUp) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.read<FolderBloc>().add(const NavigateUp());
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: BlocBuilder<FolderBloc, FolderState>(
        builder: (context, state) {
          if (state is FolderLoading || state is FolderInitial) {
            return const LoadingStateWidget();
          }

          if (state is FolderError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: _loadFolders,
            );
          }

          if (state is FoldersLoaded) {
            final folders = state.visibleFolders;
            final songs = state.currentSongs;

            if (folders.isEmpty && songs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.folder,
                title: 'No folders found',
                subtitle: 'Scan your music library first',
                action: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Go to Songs'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadFolders();
              },
              child: CustomScrollView(
                slivers: [
                  if (folders.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: ListTile(
                        title: Text('Folders'),
                        dense: true,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final folder = folders[index];
                          return FolderTile(
                            folder: folder,
                            onTap: () {
                              context.read<FolderBloc>().add(NavigateToFolder(folder));
                            },
                          );
                        },
                        childCount: folders.length,
                      ),
                    ),
                  ],
                  if (songs.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Songs (${songs.length})'),
                            dense: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => _playAll(songs),
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      ),
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
                  ],
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
}
