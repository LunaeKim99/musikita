import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musikita/features/music_player/data/datasources/audio_scan_datasource.dart';
import 'package:musikita/features/music_player/data/datasources/local_datasource.dart';
import 'package:musikita/features/music_player/data/datasources/settings_datasource.dart';
import 'package:musikita/features/music_player/data/repositories/favorite_repository_impl.dart';
import 'package:musikita/features/music_player/data/repositories/folder_repository_impl.dart';
import 'package:musikita/features/music_player/data/repositories/playlist_repository_impl.dart';
import 'package:musikita/features/music_player/data/repositories/settings_repository_impl.dart';
import 'package:musikita/features/music_player/data/repositories/song_repository_impl.dart';
import 'package:musikita/features/music_player/domain/repositories/favorite_repository.dart';
import 'package:musikita/features/music_player/domain/repositories/folder_repository.dart';
import 'package:musikita/features/music_player/domain/repositories/playlist_repository.dart';
import 'package:musikita/features/music_player/domain/repositories/settings_repository.dart';
import 'package:musikita/features/music_player/domain/repositories/song_repository.dart';
import 'package:musikita/features/music_player/domain/usecases/add_song_to_playlist.dart';
import 'package:musikita/features/music_player/domain/usecases/create_playlist.dart';
import 'package:musikita/features/music_player/domain/usecases/delete_playlist.dart';
import 'package:musikita/features/music_player/domain/usecases/export_data.dart';
import 'package:musikita/features/music_player/domain/usecases/get_available_storage_paths.dart';
import 'package:musikita/features/music_player/domain/usecases/get_folders.dart';
import 'package:musikita/features/music_player/domain/usecases/get_playlists.dart';
import 'package:musikita/features/music_player/domain/usecases/get_settings.dart';
import 'package:musikita/features/music_player/domain/usecases/get_songs.dart';
import 'package:musikita/features/music_player/domain/usecases/get_subfolders.dart';
import 'package:musikita/features/music_player/domain/usecases/import_data.dart';
import 'package:musikita/features/music_player/domain/usecases/is_favorite.dart';
import 'package:musikita/features/music_player/domain/usecases/remove_favorite.dart';
import 'package:musikita/features/music_player/domain/usecases/save_favorite.dart';
import 'package:musikita/features/music_player/domain/usecases/scan_songs.dart';
import 'package:musikita/features/music_player/domain/usecases/search_songs.dart';
import 'package:musikita/features/music_player/domain/usecases/toggle_favorite.dart';
import 'package:musikita/features/music_player/domain/usecases/update_settings.dart';
import 'package:musikita/features/music_player/domain/usecases/update_song_metadata.dart';
// ADDED: Import semua BLoC untuk didaftarkan ke GetIt
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/folder_bloc/folder_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_bloc.dart';
import 'package:musikita/features/music_player/services/audio_player_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  final localDataSource = LocalDataSourceImpl();
  await localDataSource.init();
  sl.registerSingleton<LocalDataSource>(localDataSource);

  _initCore();
  _initDataSource();
  _initRepositories();
  _initUseCases();
  _initServices();
  // ADDED: Panggil _initBlocs() untuk mendaftarkan semua BLoC
  _initBlocs();
}

void _initCore() {}

void _initDataSource() {
  sl.registerLazySingleton<SettingsDataSource>(
    () => SettingsDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AudioScanDataSource>(
    () => AudioScanDataSourceImpl(),
  );
}

void _initRepositories() {
  sl.registerLazySingleton<SongRepository>(
    () => SongRepositoryImpl(
      localDataSource: sl(),
      audioScanDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FolderRepository>(
    () => FolderRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      settingsDataSource: sl(),
      localDataSource: sl(),
    ),
  );
}

void _initUseCases() {
  sl.registerLazySingleton(() => GetSongs(sl()));
  sl.registerLazySingleton(() => SearchSongs(sl()));
  sl.registerLazySingleton(() => ScanSongs(sl()));
  sl.registerLazySingleton(() => GetAvailableStoragePaths(sl()));
  sl.registerLazySingleton(() => SaveFavorite(sl()));
  sl.registerLazySingleton(() => RemoveFavorite(sl()));
  sl.registerLazySingleton(() => IsFavorite(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => GetPlaylists(sl()));
  sl.registerLazySingleton(() => CreatePlaylist(sl()));
  sl.registerLazySingleton(() => DeletePlaylist(sl()));
  sl.registerLazySingleton(() => AddSongToPlaylist(sl()));
  sl.registerLazySingleton(() => GetFolders(sl()));
  sl.registerLazySingleton(() => GetSubfolders(sl()));
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => UpdateSettings(sl()));
  sl.registerLazySingleton(() => ExportData(sl()));
  sl.registerLazySingleton(() => ImportData(sl()));
  sl.registerLazySingleton(() => UpdateSongMetadata(sl()));
}

void _initServices() {
  sl.registerSingleton<AudioPlayerService>(AudioPlayerService());
}

// ADDED: Fungsi baru untuk mendaftarkan semua BLoC
// Menggunakan registerFactory agar setiap BlocProvider mendapatkan instance baru
// dan lifecycle-nya dikelola oleh BlocProvider (close() dipanggil otomatis)
void _initBlocs() {
  // SongBloc
  sl.registerFactory<SongBloc>(
    () => SongBloc(
      getSongs: sl(),
      searchSongs: sl(),
      scanSongs: sl(),
    ),
  );

  // PlayerBloc
  sl.registerFactory<PlayerBloc>(
    () => PlayerBloc(
      audioPlayerService: sl(),
      songRepository: sl(),
    ),
  );

  // PlaylistBloc
  sl.registerFactory<PlaylistBloc>(
    () => PlaylistBloc(
      getPlaylists: sl(),
      createPlaylist: sl(),
      deletePlaylist: sl(),
      addSongToPlaylist: sl(),
      playlistRepository: sl(),
    ),
  );

  // FavoriteBloc
  sl.registerFactory<FavoriteBloc>(
    () => FavoriteBloc(
      favoriteRepository: sl(),
      toggleFavorite: sl(),
      saveFavorite: sl(),
      removeFavorite: sl(),
      isFavorite: sl(),
    ),
  );

  // FolderBloc
  sl.registerFactory<FolderBloc>(
    () => FolderBloc(
      getFolders: sl(),
    ),
  );

  // SettingsBloc
  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      getSettings: sl(),
      updateSettings: sl(),
      exportData: sl(),
      importData: sl(),
    ),
  );

  // SearchBloc
  sl.registerFactory<SearchBloc>(
    () => SearchBloc(
      searchSongs: sl(),
    ),
  );
}
