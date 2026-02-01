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
import '../widgets/tafsir_sheet.dart';
import '../widgets/note_sheet.dart';
import '../widgets/share_sheet.dart';
import '../widgets/audio_player_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/utils/arabic_utils.dart';
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

  void _scrollToVerse(String verseKey) {
    final key = _verseKeys[verseKey];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
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

                // Track progress on first load
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(progressProvider.notifier).updateProgress(
                    widget.chapterId,
                    verses.first.verseKey,
                    chapter?.versesCount ?? verses.length,
                  );

                  // Scroll to highlighted verse
                  if (widget.highlightVerseKey != null) {
                    Future.delayed(const Duration(milliseconds: 400), () {
                      _scrollToVerse(widget.highlightVerseKey!);
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
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 42,
            color: const Color(0xFFD97706),
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
