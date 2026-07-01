import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reader_provider.dart';
import '../providers/audio_provider.dart';
import '../../home/providers/chapters_provider.dart';
import '../../home/providers/progress_provider.dart';
import '../../home/providers/bookmark_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/verse_card.dart';
import '../widgets/mushaf_view.dart';
import '../widgets/surah_header.dart';
import '../widgets/verse_actions_sheet.dart';
import '../widgets/tafsir_sheet.dart';
import '../widgets/note_sheet.dart';
import '../widgets/share_sheet.dart';
import '../widgets/audio_player_bar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../domain/entities/chapter.dart';
import '../../../domain/entities/verse.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToVerse(String verseKey) {
    final key = _verseKeys[verseKey];
    if (key?.currentContext != null) {
      final reducedMotion = ref.read(settingsProvider).reducedMotion;
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final versesAsync = ref.watch(versesProvider(widget.chapterId));
    final settings = ref.watch(settingsProvider);

    final chapter = chaptersAsync.whenOrNull(
      data: (chapters) => chapters.where((c) => c.id == widget.chapterId).firstOrNull,
    );

    final audioState = ref.watch(audioProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chapter?.nameArabic ?? 'سورة ${toArabicNumeral(widget.chapterId)}',
          style: TextStyle(fontFamily: settings.quranFont, fontSize: 22),
        ),
        actions: [
          // Reading view mode toggle (verse list <-> continuous Mushaf)
          IconButton(
            onPressed: () => ref.read(settingsProvider.notifier).setReadingViewMode(
                  settings.readingViewMode == viewModeMushaf
                      ? viewModeFlowing
                      : viewModeMushaf,
                ),
            icon: Icon(
              settings.readingViewMode == viewModeMushaf
                  ? Icons.view_agenda_outlined
                  : Icons.auto_stories_outlined,
            ),
            tooltip: settings.readingViewMode == viewModeMushaf
                ? 'عرض الآيات'
                : 'عرض المصحف',
          ),
          // Chapter audio play button
          _ChapterAudioButton(
            chapterId: widget.chapterId,
            audioState: audioState,
          ),
        ],
      ),
      body: Column(
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

                final isMushaf = settings.readingViewMode == viewModeMushaf;

                // Track progress on first load
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(progressProvider.notifier).updateProgress(
                    widget.chapterId,
                    verses.first.verseKey,
                    chapter?.versesCount ?? verses.length,
                  );

                  // Scroll to highlighted verse (verse-list view only; the
                  // Mushaf view is a single flowing block without per-verse keys)
                  if (!isMushaf && widget.highlightVerseKey != null) {
                    Future.delayed(const Duration(milliseconds: 400), () {
                      _scrollToVerse(widget.highlightVerseKey!);
                    });
                  }
                });

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
                  child: isMushaf
                      ? MushafView(
                          verses: verses,
                          chapter: chapter,
                          chapterId: widget.chapterId,
                          settings: settings,
                          controller: _scrollController,
                          highlightVerseKey: widget.highlightVerseKey,
                          playingVerseKey: audioState.isPlaying
                              ? audioState.currentVerseKey
                              : null,
                          onVerseTap: (verse) =>
                              _showVerseActions(context, verse, chapter),
                        )
                      : _buildFlowingList(verses, chapter, settings, audioState),
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

  /// The default verse-by-verse view: one [VerseCard] per verse with its own
  /// toolbar, optional translation and dividers.
  Widget _buildFlowingList(
    List<Verse> verses,
    Chapter? chapter,
    SettingsState settings,
    AudioState audioState,
  ) {
    // Build verse keys map for scroll-to-verse navigation
    for (final v in verses) {
      _verseKeys.putIfAbsent(v.verseKey, () => GlobalKey());
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: verses.length + 2, // +1 header, +1 footer
      itemBuilder: (context, index) {
        // Header
        if (index == 0) {
          return SurahHeader(
            chapter: chapter,
            chapterId: widget.chapterId,
            settings: settings,
          );
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
    );
  }

  /// Per-verse actions sheet for the Mushaf view, where verses have no inline
  /// toolbar. Triggered by tapping a verse in [MushafView].
  Future<void> _showVerseActions(BuildContext context, Verse verse, Chapter? chapter) {
    final chapterName = chapter?.nameArabic ?? '';
    final audioState = ref.read(audioProvider);
    final isPlaying =
        audioState.currentVerseKey == verse.verseKey && audioState.isPlaying;
    final isBookmarked =
        ref.read(bookmarkProvider).bookmarks.any((b) => b.verseKey == verse.verseKey);

    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VerseActionsSheet(
        verse: verse,
        chapterName: chapterName,
        settings: ref.read(settingsProvider),
        isBookmarked: isBookmarked,
        isPlaying: isPlaying,
        onBookmark: () {
          if (chapter == null) return;
          final added = ref.read(bookmarkProvider.notifier).toggleBookmark(verse, chapter);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(added ? 'تم حفظ الآية' : 'تم إزالة الإشارة'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onTafsir: () => _showTafsirSheet(context, verse, chapterName),
        onShare: () => _showShareSheet(context, verse, chapterName),
        onNote: () => _showNoteSheet(context, verse, widget.chapterId, chapterName),
        onPlay: () =>
            ref.read(audioProvider.notifier).playVerse(widget.chapterId, verse.verseKey),
      ),
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
    final theme = Theme.of(context);
    final isThisChapter = audioState.currentChapterId == chapterId && audioState.currentVerseKey == null;
    final isPlaying = isThisChapter && audioState.isPlaying;
    final isLoading = isThisChapter && audioState.isLoading;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
        ),
      );
    }

    return IconButton(
      onPressed: () => ref.read(audioProvider.notifier).playChapter(chapterId),
      icon: Icon(
        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: isThisChapter ? theme.colorScheme.primary : null,
      ),
      tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل السورة',
    );
  }
}
