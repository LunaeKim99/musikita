import 'package:dartz/dartz.dart';
import 'package:musikita/core/errors/failures.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';
import 'package:musikita/features/music_player/domain/repositories/settings_repository.dart';

class UpdateSettings {
  final SettingsRepository _repository;

  UpdateSettings(this._repository);

  Future<Either<Failure, void>> call(AppSettings settings) async {
    return _repository.updateSettings(settings);
  }
}
