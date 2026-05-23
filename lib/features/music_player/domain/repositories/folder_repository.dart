import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/folder.dart';

abstract class FolderRepository {
  Future<Either<Failure, List<Folder>>> getRootFolders();
  Future<Either<Failure, Folder>> getFolderByPath(String path);
  Future<Either<Failure, List<Folder>>> getSubfolders(String parentPath);
}
