import 'dart:io';
import 'package:musikita/core/constants/app_constants.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/features/music_player/data/models/song_model.dart';
import 'package:path/path.dart' as p;

abstract class AudioScanDataSource {
  Future<List<SongModel>> scanAudioFiles({
    List<String>? paths,
    List<String>? extensions,
  });
  Future<SongModel?> extractMetadata(String filePath);
  String? extractLrcPath(String audioFilePath);
}

class AudioScanDataSourceImpl implements AudioScanDataSource {
  @override
  Future<List<SongModel>> scanAudioFiles({
    List<String>? paths,
    List<String>? extensions,
  }) async {
    final supportedExts = (extensions ?? AppConstants.defaultCodecs)
        .map((e) => e.toLowerCase())
        .toList();

    final results = <SongModel>[];
    final searchPaths = paths ?? await _getDefaultSearchPaths();

    for (final path in searchPaths) {
      final dir = Directory(path);
      if (!await dir.exists()) continue;

      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (supportedExts.contains(ext)) {
              try {
                final metadata = await _extractBasicMetadata(entity.path);
                if (metadata != null) {
                  results.add(metadata);
                }
              } catch (e) {
                continue;
              }
            }
          }
        }
      } catch (e) {
        continue;
      }
    }

    return results;
  }

  Future<List<String>> _getDefaultSearchPaths() async {
    final paths = <String>[];

    if (Platform.isAndroid) {
      final storageDir = Directory('/storage/emulated/0');
      if (await storageDir.exists()) {
        paths.add(storageDir.path);
      }

      final musicDirs = [
        Directory('/storage/emulated/0/Music'),
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Recordings'),
      ];

      for (final dir in musicDirs) {
        if (await dir.exists() && !paths.contains(dir.path)) {
          paths.add(dir.path);
        }
      }
    } else if (Platform.isIOS) {
      try {
        final docDir = Directory(await _getIosDocumentPath());
        if (await docDir.exists()) {
          paths.add(docDir.path);
        }
      } catch (e) {
        throw PermissionException('Failed to access iOS storage');
      }
    }

    return paths;
  }

  Future<String> _getIosDocumentPath() async {
    return '/Documents';
  }

  Future<SongModel?> _extractBasicMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final fileName = p.basenameWithoutExtension(filePath);
      final parentDir = p.basename(p.dirname(filePath));

      String title = fileName;
      String artist = 'Unknown Artist';
      String album = parentDir;

      if (fileName.contains(' - ')) {
        final parts = fileName.split(' - ');
        if (parts.length >= 2) {
          artist = parts[0].trim();
          title = parts.sublist(1).join(' - ').trim();
        }
      }

      final lrcPath = extractLrcPath(filePath);
      final lrcFile = File(lrcPath);
      // bool hasLrc = await lrcFile.exists(); // TODO: Gunakan nanti untuk fitur lyrics

      int duration = 0;
      try {
        final stat = await file.stat();
        duration = (stat.size ~/ 10);
      } catch (_) {}

      return SongModel(
        title: _cleanTitle(title),
        artist: _cleanArtist(artist),
        album: _cleanAlbum(album),
        duration: duration,
        filePath: filePath,
        albumArtPath: null,
        dateAdded: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<SongModel?> extractMetadata(String filePath) async {
    return _extractBasicMetadata(filePath);
  }

  @override
  String extractLrcPath(String audioFilePath) {
    final basePath = audioFilePath.substring(0, audioFilePath.lastIndexOf('.'));
    return '$basePath${AppConstants.lrcExtension}';
  }

  String _cleanTitle(String raw) {
    var title = raw.trim();
    final patterns = [
      RegExp(r'\s*\(\d+\)$'),
      RegExp(r'\s*\[\d+\]$'),
      RegExp(r'\s*\(Official.*\)', caseSensitive: false),
      RegExp(r'\s*\[Official.*\]', caseSensitive: false),
      RegExp(r'\s*\(Lyric.*\)', caseSensitive: false),
      RegExp(r'\s*\[Lyric.*\]', caseSensitive: false),
      RegExp(r'\s*\(Audio.*\)', caseSensitive: false),
      RegExp(r'\s*\[Audio.*\]', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      title = title.replaceAll(pattern, '');
    }
    return title.isEmpty ? raw : title;
  }

  String _cleanArtist(String raw) {
    var artist = raw.trim();
    artist = artist.replaceAll(RegExp(r'\s+feat\.\s+.*$', caseSensitive: false), '');
    artist = artist.replaceAll(RegExp(r'\s+ft\.\s+.*$', caseSensitive: false), '');
    artist = artist.replaceAll(RegExp(r'\s+featuring\s+.*$', caseSensitive: false), '');
    return artist.isEmpty ? raw : artist;
  }

  String _cleanAlbum(String raw) {
    var album = raw.trim();
    return album.isEmpty ? 'Unknown Album' : album;
  }
}
