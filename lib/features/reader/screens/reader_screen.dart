import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/reader_provider.dart';
import '../providers/audio_provider.dart';
import '../../home/providers/chapters_provider.dart';
import '../../home/providers/progress_provider.dart';
import '../../home/providers/bookmark_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/verse_card.dart';
import '../widgets/tajweed_legend.dart';
import '../widgets/tafsir_sheet.dart';
import '../widgets/note_sheet.dart';
import '../widgets/share_sheet.dart';
import '../widgets/audio_player_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../domain/entities/verse.dart';
import 'mushaf_view.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final int chapterId;
  final String? highlightVerseKey;

  const ReaderScreen({
    super.key,
    required this.chapterId,
    this.highlightVerseKey,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _verseKeys = {};
  final GlobalKey<MushafPageViewState> _mushafKey = GlobalKey<MushafPageViewState>();
  bool _hasScrolledToHighlight = false;
  Future<int>? _mushafPageFuture;

  @override
  void initState() {
    super.initState();
    // Keep screen awake while reading Quran
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls to verse with retry logic for lazy-loaded ListView items
  void _scrollToVerseRobust(String verseKey, List<Verse> verses, [int attempt = 0]) {
    if (_hasScrolledToHighlight || !mounted) return;

    final key = _verseKeys[verseKey];
    if (key?.currentContext != null) {
      _hasScrolledToHighlight = true;
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
      return;
    }

    // The target verse hasn't been built yet by ListView.builder.
    // Jump to an estimated position first so it gets built.
    final verseIndex = verses.indexWhere((v) => v.verseKey == verseKey);
    if (verseIndex < 0) return;

    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      // Layout not ready yet, retry after a short delay
      if (attempt < 5) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _scrollToVerseRobust(verseKey, verses, attempt + 1);
        });
      }
      return;
    }

    // Estimate position proportionally (+1 for header item)
    final totalItems = verses.length + 2;
    final targetItem = verseIndex + 1;
    final proportion = targetItem / totalItems;
    _scrollController.jumpTo((proportion * maxScroll).clamp(0.0, maxScroll));

    // After the jump renders new items, use ensureVisible for precision
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final retryKey = _verseKeys[verseKey];
      if (retryKey?.currentContext != null) {
        _hasScrolledToHighlight = true;
        Scrollable.ensureVisible(
          retryKey!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      } else if (attempt < 5) {
        // Verse still not visible after jump, retry with adjusted estimate
        _scrollToVerseRobust(verseKey, verses, attempt + 1);
      }
    });
  }

  void _showTafsirSheet(BuildContext context, Verse verse, String chapterName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TafsirSheet(verse: verse, chapterName: chapterName),
    );
  }

  void _showNoteSheet(BuildContext context, Verse verse, int chapterId, String chapterName) {
    final existingNote = ref.read(bookmarkProvider.notifier).getNoteForVerse(verse.verseKey);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteSheet(
        verse: verse,
        chapterId: chapterId,
        chapterName: chapterName,
        existingNote: existingNote?.note,
        onSave: (note) {
          ref.read(bookmarkProvider.notifier).addNote(
            verse.verseKey, chapterId, chapterName, verse.textUthmani, note,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ الملاحظة'), duration: Duration(seconds: 1)),
          );
        },
      ),
    );
  }

  void _showShareSheet(BuildContext context, Verse verse, String chapterName) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareSheet(verse: verse, chapterName: chapterName),
    );
  }

  /// Gets the initial mushaf page, using verse-level lookup when navigating from bookmark
  Future<int> _getInitialMushafPageAsync() async {
    if (widget.highlightVerseKey != null) {
      final mushafDs = ref.read(mushafPageDataSourceProvider);
      final page = await mushafDs.getPageForVerse(widget.highlightVerseKey!);
      if (page != null) return page;
    }
    return _getInitialMushafPage();
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final versesAsync = ref.watch(versesProvider(widget.chapterId));
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    final chapter = chaptersAsync.whenOrNull(
      data: (chapters) => chapters.where((c) => c.id == widget.chapterId).firstOrNull,
    );

    final audioState = ref.watch(audioProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chapter?.nameArabic ?? 'سورة ${toArabicNumeral(widget.chapterId)}',
          style: const TextStyle(fontFamily: 'Amiri', fontSize: 22),
        ),
        actions: [
          // Tajweed legend button (show when tajweed is enabled)
          if (settings.showTajweed)
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'دليل ألوان التجويد',
              onPressed: () => TajweedLegend.show(context),
            ),
          // Mushaf/flowing toggle
          IconButton(
            icon: Icon(
              settings.readingViewMode == 'mushaf'
                  ? Icons.view_list
                  : Icons.auto_stories,
            ),
            tooltip: settings.readingViewMode == 'mushaf'
                ? 'عرض القراءة'
                : 'عرض المصحف',
            onPressed: () {
              ref.read(settingsProvider.notifier).setReadingViewMode(
                    settings.readingViewMode == 'mushaf' ? 'flowing' : 'mushaf',
                  );
            },
          ),
          // Chapter audio play button
          _ChapterAudioButton(
            chapterId: widget.chapterId,
            audioState: audioState,
          ),
        ],
      ),
      body: settings.readingViewMode == 'mushaf'
          ? _buildMushafView()
          : Column(
        children: [
          Expanded(
            child: versesAsync.when(
              data: (verses) {
                if (verses.isEmpty) {
                  return AppErrorWidget(
                    message: 'تعذر تحميل الآيات',
                    onRetry: () => ref.invalidate(versesProvider(widget.chapterId)),
                  );
                }

                // Track progress on first load
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(progressProvider.notifier).updateProgress(
                    widget.chapterId,
                    verses.first.verseKey,
                    chapter?.versesCount ?? verses.length,
                  );

                  // Scroll to highlighted verse with robust approach
                  if (widget.highlightVerseKey != null && !_hasScrolledToHighlight) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        _scrollToVerseRobust(widget.highlightVerseKey!, verses);
                      }
                    });
                  }
                });

                // Build verse keys map
                for (final v in verses) {
                  _verseKeys.putIfAbsent(v.verseKey, () => GlobalKey());
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification) {
                      // Track reading progress based on scroll position
                      final maxScroll = _scrollController.position.maxScrollExtent;
                      final currentScroll = _scrollController.offset;
                      if (maxScroll > 0) {
                        final scrollPercent = currentScroll / maxScroll;
                        final verseIndex = (scrollPercent * verses.length).clamp(0, verses.length - 1).round();
                        if (verseIndex < verses.length) {
                          ref.read(progressProvider.notifier).updateProgress(
                            widget.chapterId,
                            verses[verseIndex].verseKey,
                            chapter?.versesCount ?? verses.length,
                          );
                        }
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: verses.length + 2, // +1 header, +1 footer
                    itemBuilder: (context, index) {
                      // Header
                      if (index == 0) {
                        return _buildHeader(chapter, settings, theme);
                      }

                      // Footer padding
                      if (index == verses.length + 1) {
                        return const SizedBox(height: 100);
                      }

                      final verse = verses[index - 1];
                      final isHighlighted = verse.verseKey == widget.highlightVerseKey;
                      final isCurrentVerse = audioState.currentVerseKey == verse.verseKey;

                      return VerseCard(
                        key: _verseKeys[verse.verseKey],
                        verse: verse,
                        isHighlighted: isHighlighted,
                        settings: settings,
                        onBookmarkToggle: () {
                          if (chapter == null) return;
                          final added = ref.read(bookmarkProvider.notifier).toggleBookmark(verse, chapter);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(added ? 'تم حفظ الآية' : 'تم إزالة الإشارة'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        isBookmarked: ref.watch(bookmarkProvider).bookmarks.any((b) => b.verseKey == verse.verseKey),
                        onTafsir: () => _showTafsirSheet(context, verse, chapter?.nameArabic ?? ''),
                        onShare: () => _showShareSheet(context, verse, chapter?.nameArabic ?? ''),
                        onNote: () => _showNoteSheet(context, verse, widget.chapterId, chapter?.nameArabic ?? ''),
                        onPlay: () {
                          ref.read(audioProvider.notifier).playVerse(widget.chapterId, verse.verseKey);
                        },
                        isPlayingAudio: isCurrentVerse && audioState.isPlaying,
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(message: 'جاري تحميل الآيات...'),
              error: (error, _) => AppErrorWidget(
                message: 'تعذر تحميل الآيات',
                onRetry: () => ref.invalidate(versesProvider(widget.chapterId)),
              ),
            ),
          ),
          // Audio player bar at bottom
          const AudioPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildMushafView() {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<int>(
            future: _mushafPageFuture ??= _getInitialMushafPageAsync(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return MushafPageView(
                key: _mushafKey,
                initialPage: snapshot.data!,
                highlightVerseKey: widget.highlightVerseKey,
              );
            },
          ),
        ),
        const AudioPlayerBar(),
      ],
    );
  }

  int _getInitialMushafPage() {
    const chapterToPage = <int, int>{
      1: 1, 2: 2, 3: 50, 4: 77, 5: 106, 6: 128, 7: 151, 8: 177, 9: 187,
      10: 208, 11: 221, 12: 235, 13: 249, 14: 255, 15: 262, 16: 267,
      17: 282, 18: 293, 19: 305, 20: 312, 21: 322, 22: 332, 23: 342,
      24: 350, 25: 359, 26: 367, 27: 377, 28: 385, 29: 396, 30: 404,
      31: 411, 32: 415, 33: 418, 34: 428, 35: 434, 36: 440, 37: 446,
      38: 453, 39: 458, 40: 467, 41: 477, 42: 483, 43: 489, 44: 496,
      45: 499, 46: 502, 47: 507, 48: 511, 49: 515, 50: 518, 51: 520,
      52: 523, 53: 526, 54: 528, 55: 531, 56: 534, 57: 537, 58: 542,
      59: 545, 60: 549, 61: 551, 62: 553, 63: 554, 64: 556, 65: 558,
      66: 560, 67: 562, 68: 564, 69: 566, 70: 568, 71: 570, 72: 572,
      73: 574, 74: 575, 75: 577, 76: 578, 77: 580, 78: 582, 79: 583,
      80: 585, 81: 586, 82: 587, 83: 587, 84: 589, 85: 590, 86: 591,
      87: 591, 88: 592, 89: 593, 90: 594, 91: 595, 92: 595, 93: 596,
      94: 596, 95: 597, 96: 597, 97: 598, 98: 598, 99: 599, 100: 599,
      101: 600, 102: 600, 103: 601, 104: 601, 105: 601, 106: 602,
      107: 602, 108: 602, 109: 603, 110: 603, 111: 603, 112: 604,
      113: 604, 114: 604,
    };
    return chapterToPage[widget.chapterId] ?? 1;
  }

  Widget _buildHeader(dynamic chapter, SettingsState settings, ThemeData theme) {
    final showBismillah = chapter?.bismillahPre ?? true;
    // Surah At-Tawbah (9) has no bismillah
    final isTawbah = widget.chapterId == 9;

    return Column(
      children: [
        const SizedBox(height: 16),
        // Chapter name
        Text(
          chapter?.nameArabic ?? '',
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 42,
            color: Color(0xFFD97706),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${chapter?.revelationPlace == "makkah" ? "مكية" : "مدنية"} \u2022 ${toArabicNumeral(chapter?.versesCount ?? 0)} آية',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Bismillah
        if (showBismillah && !isTawbah) ...[
          Text(
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
            style: TextStyle(
              fontFamily: settings.quranFont,
              fontSize: 28,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],

        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// App bar button for chapter-level audio playback
class _ChapterAudioButton extends ConsumerWidget {
  final int chapterId;
  final AudioState audioState;

  const _ChapterAudioButton({
    required this.chapterId,
    required this.audioState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isThisChapter = audioState.currentChapterId == chapterId && audioState.currentVerseKey == null;
    final isPlaying = isThisChapter && audioState.isPlaying;
    final isLoading = isThisChapter && audioState.isLoading;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD97706)),
        ),
      );
    }

    return IconButton(
      onPressed: () => ref.read(audioProvider.notifier).playChapter(chapterId),
      icon: Icon(
        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: isThisChapter ? const Color(0xFFD97706) : null,
      ),
      tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل السورة',
    );
  }
}
