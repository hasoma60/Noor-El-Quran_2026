import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/services/app_logger.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../home/providers/chapters_provider.dart';
import '../../settings/providers/settings_provider.dart';

/// Audio playback state
class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final int? currentChapterId;
  final String? currentVerseKey;
  final double playbackSpeed;
  final int repeatCount;
  final Duration duration;
  final Duration position;
  final int currentRepeat;

  const AudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentChapterId,
    this.currentVerseKey,
    this.playbackSpeed = 1.0,
    this.repeatCount = 1,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.currentRepeat = 0,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    int? currentChapterId,
    String? currentVerseKey,
    double? playbackSpeed,
    int? repeatCount,
    Duration? duration,
    Duration? position,
    int? currentRepeat,
    bool clearChapter = false,
    bool clearVerse = false,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentChapterId: clearChapter ? null : (currentChapterId ?? this.currentChapterId),
      currentVerseKey: clearVerse ? null : (currentVerseKey ?? this.currentVerseKey),
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      repeatCount: repeatCount ?? this.repeatCount,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      currentRepeat: currentRepeat ?? this.currentRepeat,
    );
  }

  bool get hasAudio => currentChapterId != null || currentVerseKey != null;

  String get positionText => _formatDuration(position);
  String get durationText => _formatDuration(duration);

  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Audio notifier wrapping just_audio AudioPlayer
class AudioNotifier extends StateNotifier<AudioState> {
  static const _log = AppLogger('AudioNotifier');
  final AudioPlayer _player;
  final QuranRepository _repository;
  final Ref _ref;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;

  AudioNotifier(this._player, this._repository, this._ref) : super(const AudioState()) {
    _setupListeners();
  }

  void _setupListeners() {
    _playerStateSub = _player.playerStateStream.listen((playerState) {
      final playing = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        _handlePlaybackComplete();
      } else {
        state = state.copyWith(
          isPlaying: playing,
          isLoading: processingState == ProcessingState.loading || processingState == ProcessingState.buffering,
        );
      }
    });

    _durationSub = _player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    _positionSub = _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });
  }

  void _handlePlaybackComplete() {
    final nextRepeat = state.currentRepeat + 1;
    if (nextRepeat < state.repeatCount) {
      // Repeat: seek to beginning and play again
      state = state.copyWith(currentRepeat: nextRepeat);
      _player.seek(Duration.zero);
      _player.play();
    } else {
      // Done with all repeats
      state = state.copyWith(
        isPlaying: false,
        currentRepeat: 0,
        position: Duration.zero,
      );
    }
  }

  /// Play chapter audio (toggle if same chapter)
  Future<void> playChapter(int chapterId, {int? reciterId}) async {
    // Toggle if same chapter is playing (not verse mode)
    if (state.currentChapterId == chapterId && state.currentVerseKey == null) {
      if (state.isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    // Get reciter IDs
    final effectiveReciterId = reciterId ?? _ref.read(settingsProvider).selectedReciterId;
    final apiIds = getReciterApiIds(effectiveReciterId);

    state = state.copyWith(
      isLoading: true,
      currentChapterId: chapterId,
      clearVerse: true,
      currentRepeat: 0,
    );

    final url = await _repository.getChapterAudioUrl(chapterId, apiIds.chapterApiId);
    if (url != null) {
      try {
        await _player.setUrl(url);
        await _player.setSpeed(state.playbackSpeed);
        await _player.play();
      } catch (e) {
        _log.error('Failed to play chapter $chapterId audio', e);
        state = state.copyWith(isLoading: false, isPlaying: false);
      }
    } else {
      _log.warning('No audio URL found for chapter $chapterId');
      state = state.copyWith(isLoading: false, isPlaying: false);
    }
  }

  /// Play single verse audio (toggle if same verse)
  Future<void> playVerse(int chapterId, String verseKey, {int? reciterId}) async {
    // Toggle if same verse is playing
    if (state.currentVerseKey == verseKey) {
      if (state.isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    // Get reciter IDs
    final effectiveReciterId = reciterId ?? _ref.read(settingsProvider).selectedReciterId;
    final apiIds = getReciterApiIds(effectiveReciterId);

    // Check if this reciter supports verse recitation
    if (apiIds.verseApiId <= 0) {
      // Fall back to chapter recitation
      await playChapter(chapterId, reciterId: reciterId);
      return;
    }

    state = state.copyWith(
      isLoading: true,
      currentChapterId: chapterId,
      currentVerseKey: verseKey,
      currentRepeat: 0,
    );

    final url = await _repository.getVerseAudioUrl(verseKey, apiIds.verseApiId);
    if (url != null) {
      try {
        await _player.setUrl(url);
        await _player.setSpeed(state.playbackSpeed);
        await _player.play();
      } catch (e) {
        _log.error('Failed to play verse $verseKey audio', e);
        state = state.copyWith(isLoading: false, isPlaying: false);
      }
    } else {
      _log.warning('No audio URL found for verse $verseKey');
      state = state.copyWith(isLoading: false, isPlaying: false);
    }
  }

  /// Toggle play/pause
  Future<void> togglePlay() async {
    if (!state.hasAudio) return;
    if (state.isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// Stop playback and clear state
  Future<void> stop() async {
    await _player.stop();
    state = const AudioState();
  }

  /// Set playback speed (0.5x - 2.0x)
  void setPlaybackSpeed(double speed) {
    final clamped = speed.clamp(0.5, 2.0);
    state = state.copyWith(playbackSpeed: clamped);
    _player.setSpeed(clamped);
  }

  /// Set repeat count (1-10)
  void setRepeatCount(int count) {
    state = state.copyWith(repeatCount: count.clamp(1, 10), currentRepeat: 0);
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    state = state.copyWith(position: position);
  }

  /// Seek by percentage (0.0 - 1.0)
  Future<void> seekToPercent(double percent) async {
    final targetMs = (state.duration.inMilliseconds * percent.clamp(0.0, 1.0)).round();
    await seek(Duration(milliseconds: targetMs));
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

/// Riverpod provider for audio player instance
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

/// Riverpod provider for audio state
final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  final player = ref.watch(audioPlayerProvider);
  final repository = ref.watch(quranRepositoryProvider);
  return AudioNotifier(player, repository, ref);
});
