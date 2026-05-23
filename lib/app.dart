import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/core/theme/app_theme.dart';
import 'package:musikita/core/di/injection_container.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/folder_bloc/folder_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_state.dart';
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
import 'package:musikita/features/music_player/presentation/widgets/app_sidebar.dart';
import 'package:musikita/features/music_player/presentation/widgets/mini_player_widget.dart';

final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();

ThemeMode _mapToThemeMode(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.amoled:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
}

ThemeData _getDarkTheme(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.amoled:
      return AppTheme.amoled();
    case AppThemeMode.dark:
      return AppTheme.dark();
    case AppThemeMode.light:
      return AppTheme.dark();
    case AppThemeMode.system:
      return AppTheme.dark();
  }
}

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
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider<SongBloc>(
          create: (context) => sl<SongBloc>(),
        ),
        BlocProvider<PlayerBloc>(
          create: (context) => sl<PlayerBloc>(),
        ),
        BlocProvider<PlaylistBloc>(
          create: (context) => sl<PlaylistBloc>(),
        ),
        BlocProvider<FavoriteBloc>(
          create: (context) => sl<FavoriteBloc>(),
        ),
        BlocProvider<FolderBloc>(
          create: (context) => sl<FolderBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => sl<SettingsBloc>()..add(LoadSettings()),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => sl<SearchBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final AppThemeMode themeMode = state is SettingsLoaded
              ? state.settings.themeMode
              : AppThemeMode.system;

          return MaterialApp(
            title: 'Musikita',
            theme: AppTheme.light(),
            darkTheme: _getDarkTheme(themeMode),
            themeMode: _mapToThemeMode(themeMode),
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
              '/settings': (context) => const SettingsPage(),
              '/folder-browser': (context) => const FolderPage(),
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
          );
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
      key: mainScaffoldKey,
      drawer: const AppSidebar(),
      body: Column(
        children: [
          Expanded(
            child: pages[selectedIndex],
          ),
          BlocBuilder<PlayerBloc, MusicPlayerState>(
            builder: (context, state) {
              bool hasPlayer = false;
              if (state is PlayerReady) {
                hasPlayer = state.currentSong != null;
              }
              if (hasPlayer) {
                return const MiniPlayerWidget();
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
