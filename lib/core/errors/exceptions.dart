import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  final String message;

  const AppException(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

class PermissionException extends AppException {
  const PermissionException(super.message);
}

class StorageException extends AppException {
  const StorageException(super.message);
}

class AudioException extends AppException {
  const AudioException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class SettingsException extends AppException {
  const SettingsException(super.message);
}
