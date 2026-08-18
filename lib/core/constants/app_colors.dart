import 'package:flutter/material.dart';

/// Central palette. Six ramps + neutral tones, 8px spacing system.
abstract class AppColors {
  AppColors._();

  // Primary (deep blue)
  static const Color primary = Color(0xFF1B6EF3);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF6FA8FF);

  // Secondary (teal)
  static const Color secondary = Color(0xFF12B5A0);
  static const Color secondaryDark = Color(0xFF00796B);

  // Accent (amber)
  static const Color accent = Color(0xFFFFB300);
  static const Color accentDark = Color(0xFFFF8F00);

  // Success / Warning / Error
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE53935);

  // Neutral ramp
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF7F8FA);
  static const Color neutral100 = Color(0xFFEDEEF1);
  static const Color neutral200 = Color(0xFFD7DAE0);
  static const Color neutral400 = Color(0xFF9AA0AB);
  static const Color neutral600 = Color(0xFF5B626D);
  static const Color neutral800 = Color(0xFF2C3038);
  static const Color neutral900 = Color(0xFF171A1F);
}

abstract class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract class AppRadii {
  AppRadii._();
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}
