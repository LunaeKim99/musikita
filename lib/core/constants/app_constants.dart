class AppConstants {
  static const String appName = 'Musikita';

  static const String databaseName = 'musikita.db';
  static const int databaseVersion = 2;

  static const List<String> supportedCodecs = [
    '.mp3',
    '.flac',
    '.aac',
    '.ogg',
    '.wav',
    '.m4a',
    '.opus',
    '.wma',
  ];

  static const List<String> defaultCodecs = [
    '.mp3',
    '.flac',
    '.aac',
    '.ogg',
    '.m4a',
  ];

  static const String lrcExtension = '.lrc';

  static const Duration lrcDelayThreshold = Duration(milliseconds: 50);

  static const int recentPlayedLimit = 50;

  static const int exportJsonVersion = 1;

  static const String exportFileName = 'musikita_backup.json';
}
