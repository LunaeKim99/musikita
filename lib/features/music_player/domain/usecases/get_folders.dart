import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/folder.dart';
import 'package:musikita/features/music_player/domain/repositories/folder_repository.dart';

class GetFolders {
  final FolderRepository _repository;

  GetFolders(this._repository);

  Future<Either<Failure, List<Folder>>> call() async {
    return _repository.getRootFolders();
  }
}
