import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/reader/providers/audio_provider.dart';
import '../router/route_names.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/bookmarks')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);
    final audioState = ref.watch(audioProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini audio player (shows when audio is active)
          if (audioState.hasAudio)
            _MiniAudioPlayer(audioState: audioState, theme: theme),

          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.goNamed(RouteNames.home);
                case 1:
                  context.goNamed(RouteNames.bookmarks);
                case 2:
                  context.goNamed(RouteNames.settings);
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline),
                selectedIcon: Icon(Icons.bookmark),
                label: 'المفضلة',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'الإعدادات',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mini audio player shown above the bottom navigation bar
class _MiniAudioPlayer extends ConsumerWidget {
  final AudioState audioState;
  final ThemeData theme;

  const _MiniAudioPlayer({required this.audioState, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thin progress bar
          LinearProgressIndicator(
            value: audioState.progress,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation(Color(0xFFD97706)),
            minHeight: 2,
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                // Playing indicator
                const Icon(
                  Icons.music_note,
                  size: 16,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 8),

                // Info text
                Expanded(
                  child: Text(
                    audioState.currentVerseKey != null
                        ? 'الآية ${audioState.currentVerseKey}'
                        : 'سورة ${audioState.currentChapterId ?? ""}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Play/pause
                InkWell(
                  onTap: () => ref.read(audioProvider.notifier).togglePlay(),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: audioState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD97706)),
                          )
                        : Icon(
                            audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 24,
                            color: const Color(0xFFD97706),
                          ),
                  ),
                ),

                const SizedBox(width: 4),

                // Stop
                InkWell(
                  onTap: () => ref.read(audioProvider.notifier).stop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
