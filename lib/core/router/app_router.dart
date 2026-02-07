import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/reader/screens/reader_screen.dart';
import '../../features/bookmarks/screens/bookmarks_screen.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/juz_navigator/screens/juz_navigator_screen.dart';
import '../../features/khatmah/screens/khatmah_screen.dart';
import '../../features/memorization/screens/memorization_screen.dart';
import '../../features/stats/screens/stats_screen.dart';
import '../../features/thematic/screens/thematic_screen.dart';
import '../widgets/app_shell.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: RouteNames.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/bookmarks',
          name: RouteNames.bookmarks,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BookmarksScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          name: RouteNames.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/reader/:chapterId',
      name: RouteNames.reader,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final chapterId = int.parse(state.pathParameters['chapterId']!);
        final verseKey = state.uri.queryParameters['verse'];
        return ReaderScreen(chapterId: chapterId, highlightVerseKey: verseKey);
      },
    ),
    GoRoute(
      path: '/notes',
      name: RouteNames.notes,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: '/juz',
      name: RouteNames.juz,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const JuzNavigatorScreen(),
    ),
    GoRoute(
      path: '/khatmah',
      name: RouteNames.khatmah,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const KhatmahScreen(),
    ),
    GoRoute(
      path: '/memorization',
      name: RouteNames.memorization,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MemorizationScreen(),
    ),
    GoRoute(
      path: '/stats',
      name: RouteNames.stats,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/thematic',
      name: RouteNames.thematic,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ThematicScreen(),
    ),
  ],
);
