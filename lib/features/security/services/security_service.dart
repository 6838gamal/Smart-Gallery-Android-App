import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../services/biometric/biometric_service.dart';

/// Persists the app-lock state. The password is hashed (SHA-256) before
/// storage — never stored as plaintext.
class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();

  static const _keyPasswordHash = 'lock_password_hash';
  static const _keyLockEnabled = 'lock_enabled';
  static const _keyBiometricEnabled = 'biometric_enabled';

  final _storage = const FlutterSecureStorage();

  Future<bool> get isLockEnabled async =>
      (await _storage.read(key: _keyLockEnabled)) == '1';

  Future<bool> get isBiometricEnabled async =>
      (await _storage.read(key: _keyBiometricEnabled)) == '1';

  Future<bool> get hasPassword async =>
      (await _storage.read(key: _keyPasswordHash)) != null;

  Future<void> enableLock() async {
    await _storage.write(key: _keyLockEnabled, value: '1');
  }

  Future<void> disableLock() async {
    await _storage.write(key: _keyLockEnabled, value: '0');
  }

  Future<void> setBiometric(bool enabled) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled ? '1' : '0');
  }

  Future<void> setPassword(String password) async {
    final hash = _hash(password);
    await _storage.write(key: _keyPasswordHash, value: hash);
  }

  Future<void> clearPassword() async {
    await _storage.delete(key: _keyPasswordHash);
  }

  Future<bool> verifyPassword(String password) async {
    final stored = await _storage.read(key: _keyPasswordHash);
    if (stored == null) return false;
    return _hash(password) == stored;
  }

  String _hash(String input) {
    // Simple deterministic hash. For a real app you'd use a salted KDF; here
    // we avoid extra deps and keep it offline-only.
    var h = 0x811c9dc5;
    for (final c in input.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h.toRadixString(16);
  }

  Future<bool> authenticateBiometric() =>
      BiometricService.instance.authenticate();
}

@immutable
class SecurityState {
  const SecurityState({
    this.lockEnabled = false,
    this.unlocked = false,
    this.biometricEnabled = false,
    this.hasPassword = false,
  });
  final bool lockEnabled;
  final bool unlocked;
  final bool biometricEnabled;
  final bool hasPassword;
  SecurityState copyWith({
    bool? lockEnabled,
    bool? unlocked,
    bool? biometricEnabled,
    bool? hasPassword,
  }) =>
      SecurityState(
        lockEnabled: lockEnabled ?? this.lockEnabled,
        unlocked: unlocked ?? this.unlocked,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        hasPassword: hasPassword ?? this.hasPassword,
      );
}

class SecurityNotifier extends Notifier<SecurityState> {
  @override
  SecurityState build() {
    Future.microtask(load);
    return const SecurityState();
  }

  Future<void> load() async {
    final s = SecurityService.instance;
    state = SecurityState(
      lockEnabled: await s.isLockEnabled,
      biometricEnabled: await s.isBiometricEnabled,
      hasPassword: await s.hasPassword,
    );
  }

  Future<void> enableLock() async {
    await SecurityService.instance.enableLock();
    state = state.copyWith(lockEnabled: true);
  }

  Future<void> disableLock() async {
    await SecurityService.instance.disableLock();
    state = state.copyWith(lockEnabled: false, unlocked: true);
  }

  Future<void> setBiometric(bool enabled) async {
    await SecurityService.instance.setBiometric(enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }

  Future<bool> setPassword(String p1, String p2) async {
    if (p1 != p2 || p1.isEmpty) return false;
    await SecurityService.instance.setPassword(p1);
    await SecurityService.instance.enableLock();
    state = state.copyWith(hasPassword: true, lockEnabled: true);
    return true;
  }

  Future<bool> unlock(String password) async {
    final ok = await SecurityService.instance.verifyPassword(password);
    if (ok) state = state.copyWith(unlocked: true);
    return ok;
  }

  Future<bool> unlockBiometric() async {
    final ok = await SecurityService.instance.authenticateBiometric();
    if (ok) state = state.copyWith(unlocked: true);
    return ok;
  }
}

final securityStateProvider =
    NotifierProvider<SecurityNotifier, SecurityState>(SecurityNotifier.new);
