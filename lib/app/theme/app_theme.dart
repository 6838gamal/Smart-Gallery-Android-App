import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart'; // ✅ تأكد من صحة المسار

/// Material 3 theme built from [AppColors]. Light + dark variants.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.neutral0,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.neutral50,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral0,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _titleStyle(AppColors.neutral900),
      ),
      cardColor: AppColors.neutral0,
      dividerColor: AppColors.neutral200,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.neutral900,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.neutral900,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral900,
        foregroundColor: AppColors.neutral0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _titleStyle(AppColors.neutral0),
      ),
      cardColor: AppColors.neutral800,
      dividerColor: AppColors.neutral800,
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        },
      ),
    );
    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      // ✅ إصلاح: استخدام CardThemeData بدلاً من CardTheme
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
    );
  }

  static TextStyle _titleStyle(Color c) => TextStyle(
        color: c,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextTheme _textTheme(TextTheme base) => base.copyWith(
        titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: base.bodyMedium?.copyWith(height: 1.5),
        labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      );
}
