import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/security/services/security_service.dart';

/// Exposes a `Listenable` GoRouter can watch, plus the current lock state.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<SecurityState>(securityStateProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;

  bool get shouldLock {
    final s = _ref.read(securityStateProvider);
    return s.lockEnabled && !s.unlocked;
  }
}

/// `ChangeNotifierProvider` lets GoRouter's `refreshListenable` react to
/// security-state changes (lock enabled/disabled, unlocked).
final routerNotifierProvider =
    ChangeNotifierProvider<RouterNotifier>(RouterNotifier.new);
