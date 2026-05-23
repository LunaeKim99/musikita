import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/core/theme/app_theme.dart';
import 'package:musikita/core/di/injection_container.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/folder_bloc/folder_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_state.dart' as ps;
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_bloc.dart';
import 'package:musikita/features/music_player/presentation/pages/edit_cover_page.dart';
import 'package:musikita/features/music_player/presentation/pages/edit_metadata_page.dart';
import 'package:musikita/features/music_player/presentation/pages/favorite_page.dart';
import 'package:musikita/features/music_player/presentation/pages/folder_page.dart';
import 'package:musikita/features/music_player/presentation/pages/now_playing_page.dart';
import 'package:musikita/features/music_player/presentation/pages/playlist_detail_page.dart';
import 'package:musikita/features/music_player/presentation/pages/playlist_page.dart';
import 'package:musikita/features/music_player/presentation/pages/search_page.dart';
import 'package:musikita/features/music_player/presentation/pages/settings_page.dart';
import 'package:musikita/features/music_player/presentation/pages/song_list_page.dart';

class MusikitaApp extends StatefulWidget {
  const MusikitaApp({super.key});

  @override
  State<MusikitaApp> createState() => _MusikitaAppState();
}

class _MusikitaAppState extends State<MusikitaApp> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const SongListPage(),
      const PlaylistPage(),
      const FavoritePage(),
      const FolderPage(),
      const SettingsPage(),
    ];

    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.music_note_outlined),
        selectedIcon: Icon(Icons.music_note),
        label: 'Songs',
      ),
      NavigationDestination(
        icon: Icon(Icons.playlist_play_outlined),
        selectedIcon: Icon(Icons.playlist_play),
        label: 'Playlists',
      ),
      NavigationDestination(
        icon: Icon(Icons.favorite_border),
        selectedIcon: Icon(Icons.favorite),
        label: 'Favorites',
      ),
      NavigationDestination(
        icon: Icon(Icons.folder_outlined),
        selectedIcon: Icon(Icons.folder),
        label: 'Folders',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider<SongBloc>(
          create: (context) => SongBloc(
            getSongs: sl(),
            searchSongs: sl(),
            scanSongs: sl(),
          ),
        ),
        BlocProvider<PlayerBloc>(
          create: (context) => PlayerBloc(
            audioPlayerService: sl(),
          ),
        ),
        BlocProvider<PlaylistBloc>(
          create: (context) => PlaylistBloc(
            getPlaylists: sl(),
            createPlaylist: sl(),
            deletePlaylist: sl(),
            addSongToPlaylist: sl(),
            playlistRepository: sl(),
          ),
        ),
        BlocProvider<FavoriteBloc>(
          create: (context) => FavoriteBloc(
            favoriteRepository: sl(),
            toggleFavorite: sl(),
            saveFavorite: sl(),
            removeFavorite: sl(),
            isFavorite: sl(),
          ),
        ),
        BlocProvider<FolderBloc>(
          create: (context) => FolderBloc(
            getFolders: sl(),
          ),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(
            getSettings: sl(),
            updateSettings: sl(),
            exportData: sl(),
            importData: sl(),
          ),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
            searchSongs: sl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Musikita',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: _MainPage(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          pages: pages,
          destinations: destinations,
        ),
        routes: {
          '/now-playing': (context) => const NowPlayingPage(),
          '/search': (context) => const SearchPage(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/playlist-detail':
              final playlist = settings.arguments as Playlist;
              return MaterialPageRoute(
                builder: (context) => PlaylistDetailPage(playlist: playlist),
              );
            case '/edit-metadata':
              final song = settings.arguments as Song;
              return MaterialPageRoute(
                builder: (context) => EditMetadataPage(song: song),
              );
            case '/edit-cover':
              final song = settings.arguments as Song;
              return MaterialPageRoute(
                builder: (context) => EditCoverPage(song: song),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

class _MainPage extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<Widget> pages;
  final List<NavigationDestination> destinations;

  const _MainPage({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.pages,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: pages[selectedIndex],
          ),
          BlocBuilder<PlayerBloc, ps.MusicPlayerState>(
            builder: (context, state) {
              bool hasPlayer = false;
              if (state is ps.PlayerReady) {
                hasPlayer = state.currentSong != null;
              }
              if (hasPlayer) {
                return const _MiniPlayerWidget();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}

class _MiniPlayerWidget extends StatelessWidget {
  const _MiniPlayerWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, ps.MusicPlayerState>(
      builder: (context, state) {
        if (state is! ps.PlayerReady) return const SizedBox.shrink();

        final currentSong = state.currentSong;
        if (currentSong == null) return const SizedBox.shrink();

        final isPlaying = state.isPlaying;

        return Container(
          width: double.infinity,
          height: 72,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: state.progressPercent,
                minHeight: 2,
              ),
              Expanded(
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    currentSong.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    currentSong.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            context.read<PlayerBloc>().add(const PausePlayback());
                          } else {
                            context.read<PlayerBloc>().add(const ResumePlayback());
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/now-playing');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
