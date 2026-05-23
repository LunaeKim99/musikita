import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/repositories/settings_repository.dart';

class ExportData {
  final SettingsRepository _repository;

  ExportData(this._repository);

  Future<Either<Failure, String>> call() async {
    return _repository.exportToJson();
  }
}
