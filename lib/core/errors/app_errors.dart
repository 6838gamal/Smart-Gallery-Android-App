/// Base type for all recoverable failures in the app.
///
/// Failures carry a localized message key (consumed by the UI via
/// `AppLocalizations`) and an optional technical cause used for logging only.
sealed class AppError {
  const AppError(this.messageKey, {this.cause});
  final String messageKey;
  final Object? cause;

  @override
  String toString() => '$runtimeType($messageKey)';
}

final class PermissionDeniedError extends AppError {
  const PermissionDeniedError() : super('permissionDenied');
}

final class FileCorruptedError extends AppError {
  const FileCorruptedError({super.cause}) : super('fileCorrupted');
}

final class UnsupportedFormatError extends AppError {
  const UnsupportedFormatError({super.cause}) : super('unsupportedFormat');
}

final class DatabaseError extends AppError {
  const DatabaseError({super.cause}) : super('databaseError');
}

final class AISearchError extends AppError {
  const AISearchError({super.cause}) : super('aiNotAvailable');
}

final class EditorError extends AppError {
  const EditorError({super.cause}) : super('editorError');
}

final class SaveError extends AppError {
  const SaveError({super.cause}) : super('saveFailed');
}
