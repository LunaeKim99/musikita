# Changelog

All notable changes to Musikita will be documented in this file.

## [Unreleased]

## [0.1.0] - 2026-05-23

### Added
- **Sidebar/Drawer** with logo, Folders, Scan, Settings, and 5 recently played songs
- **Permission Dialog** with storage permission explanation, request flow, and settings redirect
- **Storage Permissions** in AndroidManifest: `READ_EXTERNAL_STORAGE`, `READ_MEDIA_AUDIO`, `MANAGE_EXTERNAL_STORAGE`
- **Recently Played Tracking**: PlayerBloc now tracks songs played (stored in SQLite)
- **GlobalKey** `mainScaffoldKey` for drawer access from child pages
- **Assets section** in pubspec.yaml for `assets/images/`
- **New Widgets**: `AppSidebar`, `PermissionDialog`

### Changed
- **Navigation**: 3 bottom tabs (Songs, Playlists, Favorites) + sidebar for Settings & Folders
- **Permission Check**: Moved from `SongRepositoryImpl` to UI layer (`SongListPage` + `AppSidebar`)
- **PlayerBloc**: Now takes `SongRepository` dependency for recent played tracking
- **Injection Container**: Updated to pass `SongRepository` to `PlayerBloc`
- **3 Pages**: Added hamburger menu in AppBar (SongListPage, PlaylistPage, FavoritePage)

### Removed
- Folders and Settings from bottom navigation bar
- Permission handler code from `SongRepositoryImpl.scanAndSaveSongs()`
- Unused imports from `SongRepositoryImpl`

## [0.0.3] - 2026-05-23

### Changed
- **Analyzer Fixes**: Removed all unused imports, fixed `sort_child_properties_last`, switched to initializing formals
- **PlayerState**: Renamed to `MusicPlayerState` to avoid conflict with just_audio's `PlayerState`
- **Enums**: Moved `PlayerStateType` and `RepeatModeState` to separate `player_enums.dart`
- **Mini Player**: Connected to `PlayerBloc` properly
- **Duration Calculation**: Uses actual just_audio extraction instead of file size approximation
- **iOS Path**: Uses `path_provider.getApplicationDocumentsDirectory()` instead of hardcoded `/Documents`
- **BLoC Registrations**: All BLoCs registered with `registerFactory` in GetIt
- **audio_service**: Removed from pubspec (not implemented)
- **file_picker**: Reverted to stable version + `compileSdk = 34`

### Fixed
- 0 flutter analyze errors

## [0.0.2] - 2026-05-23

### Fixed
- 6+ critical issues:
  - LocalDataSource `init()` await before registration
  - Duration calculation with just_audio temp player
  - iOS document path with path_provider
  - MiniPlayer widget connected to PlayerBloc
  - `PlayerState` → `MusicPlayerState` rename for just_audio conflict
  - Enums moved to player_enums.dart

## [0.0.1] - 2026-05-23

### Added
- Initial project structure
- Clean Architecture (Presentation/Domain/Data layers)
- BLoC state management
- SQLite database with sqflite
- 7 BLoCs: Song, Player, Playlist, Favorite, Folder, Settings, Search
- 5-tab bottom navigation: Songs, Playlists, Favorites, Folders, Settings
- Metadata edit (title, artist, album, cover art)
- Export/Import (JSON)
- Favorites system
- Playlist system
- Folder browsing
