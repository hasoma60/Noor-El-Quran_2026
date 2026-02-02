import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/database_initializer.dart';
import 'data/datasources/local/quran_local_datasource.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize database and populate from bundled JSON if needed
  final db = AppDatabase();
  final initializer = DatabaseInitializer(db);
  await initializer.initializeIfNeeded();

  // Pre-initialize local Quran data for offline JSON fallback
  final localDataSource = QuranLocalDataSource(db: db);
  await localDataSource.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const NoorAlQuranApp(),
    ),
  );
}
