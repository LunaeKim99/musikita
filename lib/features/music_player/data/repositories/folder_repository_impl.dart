import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/data/datasources/local_datasource.dart';
import 'package:musikita/features/music_player/domain/entities/folder.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/folder_repository.dart';
import 'package:path/path.dart' as p;

class FolderRepositoryImpl implements FolderRepository {
  final LocalDataSource _localDataSource;

  FolderRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Folder>>> getRootFolders() async {
    try {
      final allSongs = await _localDataSource.getAllSongs();
      final folderMap = <String, List<Song>>{};

      for (final song in allSongs) {
        final dirPath = _getParentDirectory(song.filePath);
        if (dirPath != null) {
          folderMap.putIfAbsent(dirPath, () => []);
          folderMap[dirPath]!.add(song.toEntity());
        }
      }

      final rootFolders = <Folder>[];
      final rootMap = <String, List<Folder>>{};

      for (final entry in folderMap.entries) {
        final folderName = p.basename(entry.key);
        final parentPath = _getParentDirectory(entry.key);

        if (parentPath == null) {
          rootFolders.add(Folder(
            path: entry.key,
            name: folderName,
            songCount: entry.value.length,
            songs: entry.value,
          ));
        } else {
          rootMap.putIfAbsent(parentPath, () => []);
          rootMap[parentPath]!.add(Folder(
            path: entry.key,
            name: folderName,
            songCount: entry.value.length,
            songs: entry.value,
            parentPath: parentPath,
          ));
        }
      }

      for (final folder in rootFolders) {
        if (rootMap.containsKey(folder.path)) {
          folder.subfolders?.addAll(rootMap[folder.path]!);
        }
      }

      return Right(rootFolders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Folder>> getFolderByPath(String path) async {
    try {
      final allSongs = await _localDataSource.getAllSongs();
      final songsInPath = <Song>[];

      for (final song in allSongs) {
        if (song.filePath.startsWith(path)) {
          songsInPath.add(song.toEntity());
        }
      }

      final folder = Folder(
        path: path,
        name: p.basename(path),
        songCount: songsInPath.length,
        songs: songsInPath,
      );

      return Right(folder);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Folder>>> getSubfolders(String parentPath) async {
    try {
      final allSongs = await _localDataSource.getAllSongs();
      final subfolderMap = <String, List<Song>>{};

      for (final song in allSongs) {
        final dirPath = _getParentDirectory(song.filePath);
        if (dirPath != null && dirPath.startsWith(parentPath)) {
          if (dirPath != parentPath) {
            subfolderMap.putIfAbsent(dirPath, () => []);
            subfolderMap[dirPath]!.add(song.toEntity());
          }
        }
      }

      final subfolders = subfolderMap.entries.map((entry) => Folder(
            path: entry.key,
            name: p.basename(entry.key),
            songCount: entry.value.length,
            songs: entry.value,
            parentPath: parentPath,
          )).toList();

      return Right(subfolders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  String? _getParentDirectory(String filePath) {
    final lastSeparator = filePath.lastIndexOf(RegExp(r'[\\/]'));
    if (lastSeparator <= 0) return null;
    return filePath.substring(0, lastSeparator);
  }
}
