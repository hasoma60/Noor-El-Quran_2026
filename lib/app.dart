import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';

class NoorAlQuranApp extends ConsumerWidget {
  const NoorAlQuranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // Determine which theme data to use
    final ThemeData themeData;
    final ThemeData darkThemeData;
    final ThemeMode themeMode;

    if (settings.isSepia) {
      // Sepia is a light variant
      themeData = AppTheme.sepia();
      darkThemeData = AppTheme.dark();
      themeMode = ThemeMode.light;
    } else if (settings.isAmoled) {
      // AMOLED is a dark variant with pure black
      themeData = AppTheme.light();
      darkThemeData = AppTheme.amoled();
      themeMode = ThemeMode.dark;
    } else if (settings.isDarkScheduled) {
      // Night mode scheduled - force dark
      themeData = AppTheme.light();
      darkThemeData = AppTheme.dark();
      themeMode = ThemeMode.dark;
    } else {
      themeData = AppTheme.light();
      darkThemeData = AppTheme.dark();
      themeMode = settings.effectiveThemeMode;
    }

    return MaterialApp.router(
      title: 'نور القرآن',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: themeData,
      darkTheme: darkThemeData,
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
