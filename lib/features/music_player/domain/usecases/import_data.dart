import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/repositories/settings_repository.dart';

class ImportData {
  final SettingsRepository _repository;

  ImportData(this._repository);

  Future<Either<Failure, int>> call(String jsonString) async {
    return _repository.importFromJson(jsonString);
  }
}
