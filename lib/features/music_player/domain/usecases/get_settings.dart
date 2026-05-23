import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';
import 'package:musikita/features/music_player/domain/repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository _repository;

  GetSettings(this._repository);

  Future<Either<Failure, AppSettings>> call() async {
    return _repository.getSettings();
  }
}
