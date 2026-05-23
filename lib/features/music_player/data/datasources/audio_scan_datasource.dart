import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:musikita/core/constants/app_constants.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/features/music_player/data/models/song_model.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class AudioScanDataSource {
  Future<List<SongModel>> scanAudioFiles({
    List<String>? paths,
    List<String>? extensions,
  });
  Future<SongModel?> extractMetadata(String filePath);
  String? extractLrcPath(String audioFilePath);
  Future<List<String>> getAvailableStoragePaths();
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
      final internalStorage = Directory('/storage/emulated/0');
      if (await internalStorage.exists()) {
        if (!paths.contains(internalStorage.path)) {
          paths.add(internalStorage.path);
        }
      }

      final storageRoot = Directory('/storage');
      if (await storageRoot.exists()) {
        try {
          final entries = await storageRoot.list().toList();
          for (final entry in entries) {
            if (entry is Directory) {
              final path = entry.path;
              
              if (path.contains('emulated') || path.contains('self') || path.contains('legacy')) {
                continue;
              }
              
              try {
                final testDir = Directory('$path/');
                await testDir.list(recursive: false).take(1).toList();
                
                if (await entry.exists()) {
                  if (!paths.contains(path)) {
                    paths.add(path);
                  }
                }
              } catch (e) {
                continue;
              }
            }
          }
        } catch (e) {
          // Ignore errors listing /storage
        }
      }

      final mntMediaRw = Directory('/mnt/media_rw');
      if (await mntMediaRw.exists()) {
        try {
          final entries = await mntMediaRw.list().toList();
          for (final entry in entries) {
            if (entry is Directory) {
              try {
                final path = entry.path;
                final testDir = Directory('$path/');
                await testDir.list(recursive: false).take(1).toList();
                
                if (!paths.contains(path)) {
                  paths.add(path);
                }
              } catch (e) {
                continue;
              }
            }
          }
        } catch (e) {
          // Ignore access errors
        }
      }

      final sdcardPaths = [
        Directory('/storage/extSdCard'),
        Directory('/storage/sdcard1'),
        Directory('/storage/usb0'),
        Directory('/storage/usb1'),
        Directory('/storage/0000-0000'),
        Directory('/storage/1111-1111'),
        Directory('/mnt/extSdCard'),
        Directory('/mnt/sdcard'),
        Directory('/sdcard'),
        Directory('/external_sd'),
        Directory('/sdcard1'),
        Directory('/extSdCard'),
      ];

      for (final dir in sdcardPaths) {
        try {
          if (await dir.exists()) {
            await dir.list(recursive: false).take(1).toList();
            if (!paths.contains(dir.path)) {
              paths.add(dir.path);
            }
          }
        } catch (e) {
          continue;
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
    final docDir = await getApplicationDocumentsDirectory();
    return docDir.path;
  }

  @override
  Future<List<String>> getAvailableStoragePaths() async {
    return _getDefaultSearchPaths();
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

      // REMOVED: lrcPath dan lrcFile tidak digunakan di scan awal
      // LRC akan dicek di NowPlayingPage saat dibutuhkan

      int duration = await _extractDurationWithJustAudio(filePath);

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

  Future<int> _extractDurationWithJustAudio(String filePath) async {
    final tempPlayer = AudioPlayer();
    try {
      await tempPlayer.setFilePath(filePath);
      final dur = tempPlayer.duration;
      return dur?.inMilliseconds ?? 0;
    } catch (_) {
      return 0;
    } finally {
      await tempPlayer.dispose();
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
