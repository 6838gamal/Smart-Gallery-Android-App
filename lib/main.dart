import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';  // ✅ أضف هذه

import 'app/localization/app_localizations.dart';
import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/logging/app_logger.dart';
import 'features/settings/providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ تهيئة sqflite للويب
  if (kIsWeb) {
    sqfliteFfiWebInit();  // ✅ استخدم هذه للويب
    databaseFactory = databaseFactoryFfiWeb;  // ✅ استخدم هذه للويب
  } else {
    // ✅ للموبايل
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  AppLogger.init();
  runApp(const ProviderScope(child: SmartGalleryApp()));
}

class SmartGalleryApp extends ConsumerWidget {
  const SmartGalleryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    // ✅ استخدام WidgetRef مباشرة دون تحويل
    final router = buildRouter(ref);
    
    return MaterialApp.router(
      title: 'Smart Gallery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        return Directionality(
          textDirection:
              locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}
