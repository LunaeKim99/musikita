# Musikita

Flutter Local Music Player with Clean Architecture, BLoC, and SQLite.

## Features

- 🎵 **Music Playback**: Local audio file playback with just_audio
- 📱 **Modern UI**: 3-tab bottom navigation + sidebar/drawer
- 📁 **File Management**: Browse music by folders, songs, playlists
- ❤️ **Favorites**: Mark songs as favorites
- 📋 **Playlists**: Create and manage custom playlists
- 🔍 **Search**: Search songs by title, artist, album
- ⚙️ **Settings**: Theme, audio codecs, crossfade, sleep timer, volume
- 📤 **Export/Import**: Backup and restore your library
- ✏️ **Metadata Edit**: Edit song title, artist, album, cover art
- 🕐 **Recently Played**: Track your listening history
- 🔒 **Permission Handling**: Proper storage permission request dialogs

## Architecture

- **Presentation**: BLoC (Business Logic Component) for state management
- **Domain**: Use cases, entities, repository abstractions
- **Data**: Repositories, local data sources, SQLite via sqflite
- **DI**: GetIt for dependency injection

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `just_audio` | Audio playback |
| `audio_session` | Audio focus handling |
| `sqflite` + `path` | SQLite database |
| `permission_handler` | Runtime permissions |
| `shared_preferences` | App settings persistence |
| `file_picker` | File selection |
| `flex_color_scheme` | Theme styling |
| `get_it` | Dependency injection |
| `dartz` | Functional programming (Either) |

## Getting Started

### Prerequisites

- Flutter SDK (3.12.0+)
- Android Studio / VS Code
- Android device/emulator (API 21+)

### Installation

1. Clone the repo:
```bash
git clone https://github.com/LunaeKim99/musikita.git
cd musikita
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run on device/emulator:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants
│   ├── di/                 # Dependency injection (GetIt)
│   ├── errors/             # Exceptions & Failures
│   ├── theme/              # AppTheme (light/dark)
│   └── utils/              # Extensions, helpers
├── features/
│   └── music_player/
│       ├── data/
│       │   ├── datasources/  # LocalDataSource, AudioScanDataSource
│       │   ├── models/       # SongModel, PlaylistModel, etc.
│       │   └── repositories/ # Repository implementations
│       ├── domain/
│       │   ├── entities/     # Song, Playlist, Favorite, etc.
│       │   ├── repositories/ # Abstract interfaces
│       │   └── usecases/     # Use cases
│       └── presentation/
│           ├── bloc/          # 7 BLoCs (Song, Player, Playlist, etc.)
│           ├── pages/         # All UI pages
│           └── widgets/       # Reusable widgets
├── services/                  # AudioPlayerService
├── app.dart                   # Main app widget (navigation, routes)
└── main.dart                  # Entry point
```

## Permissions (Android)

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

- **Android < 10**: `READ_EXTERNAL_STORAGE`
- **Android 10-12**: `MANAGE_EXTERNAL_STORAGE` (for full file access)
- **Android 13+**: `READ_MEDIA_AUDIO`

## License

MIT License

## Contributors

- [LunaeKim99](https://github.com/LunaeKim99)
