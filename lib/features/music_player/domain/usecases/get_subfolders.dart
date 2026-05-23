import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/folder.dart';
import 'package:musikita/features/music_player/domain/repositories/folder_repository.dart';

class GetSubfolders {
  final FolderRepository _repository;

  GetSubfolders(this._repository);

  Future<Either<Failure, List<Folder>>> call(String parentPath) async {
    return _repository.getSubfolders(parentPath);
  }
}
