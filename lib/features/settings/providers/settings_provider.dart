import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/permissions/permission_service.dart';

/// Persisted user preferences: theme mode + locale.
class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('ar'),
    this.permissionGranted = false,
  });
  final ThemeMode themeMode;
  final Locale locale;
  final bool permissionGranted;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? permissionGranted,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        permissionGranted: permissionGranted ?? this.permissionGranted,
      );
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void setThemeMode(ThemeMode mode) =>
      state = state.copyWith(themeMode: mode);

  void setLocale(Locale locale) => state = state.copyWith(locale: locale);

  Future<void> ensurePermission() async {
    final granted = await PermissionService.ensureGranted();
    state = state.copyWith(permissionGranted: granted);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
