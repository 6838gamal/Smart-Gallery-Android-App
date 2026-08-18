import 'dart:io';

/// Abstraction for future backup backends (Google Drive, Supabase, S3…).
/// The MVP ships with [NoopBackupProvider] so the architecture is in place
/// without pulling in extra dependencies.
abstract class BackupProvider {
  String get displayName;
  bool get isConfigured;
  Future<void> backup(File file, String relativePath);
  Future<void> restore(String relativePath, File target);
}

class NoopBackupProvider implements BackupProvider {
  @override
  String get displayName => 'None';
  @override
  bool get isConfigured => false;
  @override
  Future<void> backup(File file, String relativePath) async {}
  @override
  Future<void> restore(String relativePath, File target) async {}
}
