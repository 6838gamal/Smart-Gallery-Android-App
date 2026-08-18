import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric + device-pin authentication wrapper.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    final can = await _auth.canCheckBiometrics;
    final supported = await _auth.isDeviceSupported();
    return can && supported;
  }

  Future<bool> authenticate({String reason = 'Unlock Smart Gallery'}) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on PlatformException {
      return false;
    }
  }
}
