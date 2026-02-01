import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../../../core/utils/arabic_utils.dart';

/// Compact audio player bar shown at the bottom of the reader screen
class AudioPlayerBar extends ConsumerWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final theme = Theme.of(context);

    if (!audioState.hasAudio) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: const Color(0xFFD97706),
              inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
              thumbColor: const Color(0xFFD97706),
              overlayColor: const Color(0xFFD97706).withValues(alpha: 0.15),
            ),
            child: Slider(
              value: audioState.progress,
              onChanged: (value) {
                ref.read(audioProvider.notifier).seekToPercent(value);
              },
            ),
          ),

          // Controls row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                // Time
                Text(
                  audioState.positionText,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),

                const Spacer(),

                // Speed button
                _SpeedButton(audioState: audioState, ref: ref, theme: theme),
                const SizedBox(width: 4),

                // Repeat button
                _RepeatButton(audioState: audioState, ref: ref, theme: theme),
                const SizedBox(width: 8),

                // Play/Pause
                _PlayPauseButton(audioState: audioState, ref: ref),
                const SizedBox(width: 8),

                // Stop
                IconButton(
                  onPressed: () => ref.read(audioProvider.notifier).stop(),
                  icon: const Icon(Icons.stop_rounded, size: 24),
                  tooltip: 'إيقاف',
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),

                const Spacer(),

                // Duration
                Text(
                  audioState.durationText,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontFeatures: const [FontFeature.tabularFigures()],
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

class _PlayPauseButton extends StatelessWidget {
  final AudioState audioState;
  final WidgetRef ref;

  const _PlayPauseButton({required this.audioState, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (audioState.isLoading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFFD97706),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () => ref.read(audioProvider.notifier).togglePlay(),
      icon: Icon(
        audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        size: 32,
      ),
      tooltip: audioState.isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
      style: IconButton.styleFrom(
        foregroundColor: const Color(0xFFD97706),
        backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.1),
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  final AudioState audioState;
  final WidgetRef ref;
  final ThemeData theme;

  const _SpeedButton({required this.audioState, required this.ref, required this.theme});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'سرعة التشغيل',
      onSelected: (speed) => ref.read(audioProvider.notifier).setPlaybackSpeed(speed),
      itemBuilder: (_) => [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
        final isSelected = audioState.playbackSpeed == speed;
        return PopupMenuItem(
          value: speed,
          child: Row(
            children: [
              if (isSelected) const Icon(Icons.check, size: 16, color: Color(0xFFD97706)),
              if (isSelected) const SizedBox(width: 8),
              Text(
                '${speed}x',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : null,
                  color: isSelected ? const Color(0xFFD97706) : null,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
        child: Text(
          '${audioState.playbackSpeed}x',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  final AudioState audioState;
  final WidgetRef ref;
  final ThemeData theme;

  const _RepeatButton({required this.audioState, required this.ref, required this.theme});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'تكرار',
      onSelected: (count) => ref.read(audioProvider.notifier).setRepeatCount(count),
      itemBuilder: (_) => [1, 2, 3, 5, 7, 10].map((count) {
        final isSelected = audioState.repeatCount == count;
        return PopupMenuItem(
          value: count,
          child: Row(
            children: [
              if (isSelected) const Icon(Icons.check, size: 16, color: Color(0xFFD97706)),
              if (isSelected) const SizedBox(width: 8),
              Text(
                count == 1 ? 'بدون تكرار' : '${toArabicNumeral(count)} مرات',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : null,
                  color: isSelected ? const Color(0xFFD97706) : null,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: audioState.repeatCount > 1
              ? const Color(0xFFD97706).withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat,
              size: 14,
              color: audioState.repeatCount > 1
                  ? const Color(0xFFD97706)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            if (audioState.repeatCount > 1) ...[
              const SizedBox(width: 2),
              Text(
                toArabicNumeral(audioState.repeatCount),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
