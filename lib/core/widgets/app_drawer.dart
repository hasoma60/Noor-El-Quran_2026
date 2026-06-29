import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';

/// Shared navigation drawer giving access to the secondary features from any
/// of the bottom-nav tabs (Home / Bookmarks / Settings). Previously these lived
/// in a Home-only AppBar overflow menu and were unreachable from other tabs.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            color: theme.colorScheme.primary,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded,
                    color: theme.colorScheme.onPrimary, size: 32),
                const SizedBox(height: 8),
                Text(
                  appName,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'v$appVersion',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Feature shortcuts
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: const [
                _DrawerItem(
                    icon: Icons.bar_chart_outlined, label: 'الإحصائيات', route: 'stats'),
                _DrawerItem(
                    icon: Icons.auto_stories_outlined, label: 'فهرس الأجزاء', route: 'juz'),
                _DrawerItem(
                    icon: Icons.calendar_month_outlined, label: 'خطة الختمة', route: 'khatmah'),
                _DrawerItem(
                    icon: Icons.note_alt_outlined, label: 'الملاحظات', route: 'notes'),
                _DrawerItem(
                    icon: Icons.school_outlined, label: 'المراجعة والحفظ', route: 'memorization'),
                _DrawerItem(
                    icon: Icons.category_outlined, label: 'الفهرس الموضوعي', route: 'thematic'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop(); // close the drawer
        context.pushNamed(route);
      },
    );
  }
}
