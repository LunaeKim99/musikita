import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/core/di/injection_container.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/usecases/get_available_storage_paths.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/widgets/empty_state_widget.dart';
import 'package:musikita/features/music_player/presentation/widgets/permission_dialog.dart';
import 'package:musikita/features/music_player/presentation/widgets/song_tile.dart';
import 'package:musikita/features/music_player/presentation/widgets/storage_selection_dialog.dart';
import 'package:musikita/app.dart' as app show mainScaffoldKey;

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  bool _getShowHiddenTracks() {
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      return settingsState.settings.showHiddenTracks;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  void _loadSongs() {
    context.read<SongBloc>().add(LoadSongs(showHidden: _getShowHiddenTracks()));
  }

  Future<void> _scanSongs() async {
    final hasPermission = await PermissionDialog.checkAndRequestStoragePermission(context);
    if (!hasPermission || !mounted) return;

    final getStoragePaths = sl<GetAvailableStoragePaths>();
    final storageResult = await getStoragePaths();

    List<String>? selectedPaths;

    storageResult.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mendapatkan storage: ${failure.message}')),
          );
        }
      },
      (paths) async {
        if (paths.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak ada storage yang ditemukan')),
            );
          }
          return;
        }

        if (paths.length == 1) {
          selectedPaths = paths;
        } else if (mounted) {
          selectedPaths = await showDialog<List<String>>(
            context: context,
            builder: (dialogContext) => StorageSelectionDialog(
              storagePaths: paths,
              initiallySelected: paths,
            ),
          );
        }
      },
    );

    if (selectedPaths != null && selectedPaths!.isNotEmpty && mounted) {
      context.read<SongBloc>().add(ScanSongsEvent(
        showHidden: _getShowHiddenTracks(),
        paths: selectedPaths,
      ));
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<SongBloc>().add(ClearSearch());
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.length >= 2) {
      context.read<SongBloc>().add(SearchSongsEvent(query, showHidden: _getShowHiddenTracks()));
    } else if (query.isEmpty) {
      context.read<SongBloc>().add(ClearSearch());
    }
  }

  void _playSong(Song song, List<Song> queue) {
    final startIndex = queue.indexWhere((s) => s.id == song.id);
    if (startIndex != -1) {
      context.read<PlayerBloc>().add(PlayFromQueue(
            songs: queue,
            initialIndex: startIndex,
          ));
    } else {
      context.read<PlayerBloc>().add(PlaySingleSong(song));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => app.mainScaffoldKey.currentState?.openDrawer(),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search songs...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text('Songs'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _scanSongs,
            tooltip: 'Scan for songs',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanSongs,
        tooltip: 'Scan Music',
        child: const Icon(Icons.folder_open),
      ),
      body: BlocBuilder<SongBloc, SongState>(
        builder: (context, state) {
          if (state is SongLoading || state is SongInitial) {
            return const LoadingStateWidget();
          }

          if (state is ScanningInProgress) {
            return LoadingStateWidget(
              message: 'Scanning music files... ${state.scannedCount} found',
            );
          }

          if (state is ScanComplete) {
            if (state.newSongsCount > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Found ${state.newSongsCount} new songs'),
                  ),
                );
              });
            }
            return _buildSongList(state.updatedSongs);
          }

          if (state is SongError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: _loadSongs,
            );
          }

          if (state is SearchResultsLoaded) {
            if (state.results.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.search_off,
                title: 'No results found',
                subtitle: 'Try searching for something else',
              );
            }
            return _buildSongList(state.results);
          }

          if (state is SongsLoaded) {
            if (state.songs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.music_note,
                title: 'No songs yet',
                subtitle: 'Tap the button below to scan your music library',
                action: ElevatedButton.icon(
                  onPressed: _scanSongs,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Scan Music'),
                ),
              );
            }
            return _buildSongList(state.songs);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSongList(List<Song> songs) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadSongs();
      },
      child: ListView.builder(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 100,
        ),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return SongTile(
            song: song,
            index: index,
            queueContext: songs,
            onTap: () => _playSong(song, songs),
          );
        },
      ),
    );
  }
}
