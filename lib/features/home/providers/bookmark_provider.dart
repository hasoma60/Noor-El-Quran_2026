import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/datasources/local/bookmark_local_datasource.dart';
import '../../../domain/entities/bookmark.dart';
import '../../../domain/entities/verse.dart';
import '../../../domain/entities/verse_note.dart';
import '../../../domain/entities/chapter.dart';
import '../../settings/providers/settings_provider.dart';

final bookmarkLocalDataSourceProvider = Provider<BookmarkLocalDataSource>((ref) {
  return BookmarkLocalDataSource(ref.watch(sharedPreferencesProvider));
});

class BookmarkState {
  final List<Bookmark> bookmarks;
  final List<VerseNote> notes;

  const BookmarkState({
    this.bookmarks = const [],
    this.notes = const [],
  });

  BookmarkState copyWith({
    List<Bookmark>? bookmarks,
    List<VerseNote>? notes,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      notes: notes ?? this.notes,
    );
  }
}

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  final BookmarkLocalDataSource _dataSource;
  static const _uuid = Uuid();

  BookmarkNotifier(this._dataSource)
      : super(BookmarkState(
          bookmarks: _dataSource.getBookmarks(),
          notes: _dataSource.getNotes(),
        ));

  // ── Bookmarks ──

  bool toggleBookmark(Verse verse, Chapter chapter, {String category = 'general'}) {
    final existing = state.bookmarks.indexWhere((b) => b.verseKey == verse.verseKey);
    List<Bookmark> updated;

    if (existing >= 0) {
      updated = List.from(state.bookmarks)..removeAt(existing);
      state = state.copyWith(bookmarks: updated);
      _dataSource.saveBookmarks(updated);
      return false;
    } else {
      final bookmark = Bookmark(
        id: verse.verseKey,
        verseKey: verse.verseKey,
        chapterId: chapter.id,
        chapterName: chapter.nameArabic,
        text: verse.textUthmani,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        category: category,
      );
      updated = [...state.bookmarks, bookmark];
      state = state.copyWith(bookmarks: updated);
      _dataSource.saveBookmarks(updated);
      return true;
    }
  }

  bool isBookmarked(String verseKey) {
    return state.bookmarks.any((b) => b.verseKey == verseKey);
  }

  void updateBookmarkCategory(String id, String category) {
    final updated = state.bookmarks.map((b) {
      if (b.id == id) return b.copyWith(category: category);
      return b;
    }).toList();
    state = state.copyWith(bookmarks: updated);
    _dataSource.saveBookmarks(updated);
  }

  void deleteBookmark(String id) {
    final updated = state.bookmarks.where((b) => b.id != id).toList();
    state = state.copyWith(bookmarks: updated);
    _dataSource.saveBookmarks(updated);
  }

  List<Bookmark> getBookmarksByCategory(String category) {
    if (category == 'all') return state.bookmarks;
    return state.bookmarks.where((b) => b.category == category).toList();
  }

  // ── Notes ──

  void addNote(String verseKey, int chapterId, String chapterName, String verseText, String note) {
    final existing = state.notes.indexWhere((n) => n.verseKey == verseKey);
    List<VerseNote> updated;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (existing >= 0) {
      updated = state.notes.map((n) {
        if (n.verseKey == verseKey) return n.copyWith(note: note, updatedAt: now);
        return n;
      }).toList();
    } else {
      updated = [
        ...state.notes,
        VerseNote(
          id: _uuid.v4(),
          verseKey: verseKey,
          chapterId: chapterId,
          chapterName: chapterName,
          verseText: verseText,
          note: note,
          createdAt: now,
          updatedAt: now,
        ),
      ];
    }
    state = state.copyWith(notes: updated);
    _dataSource.saveNotes(updated);
  }

  void updateNote(String id, String note) {
    final updated = state.notes.map((n) {
      if (n.id == id) return n.copyWith(note: note, updatedAt: DateTime.now().millisecondsSinceEpoch);
      return n;
    }).toList();
    state = state.copyWith(notes: updated);
    _dataSource.saveNotes(updated);
  }

  void deleteNote(String id) {
    final updated = state.notes.where((n) => n.id != id).toList();
    state = state.copyWith(notes: updated);
    _dataSource.saveNotes(updated);
  }

  VerseNote? getNoteForVerse(String verseKey) {
    return state.notes.where((n) => n.verseKey == verseKey).firstOrNull;
  }

  // ── Import ──

  void importBookmark(Map<String, dynamic> data) {
    final verseKey = data['verseKey'] as String? ?? '';
    // Skip duplicates
    if (state.bookmarks.any((b) => b.verseKey == verseKey)) return;

    final bookmark = Bookmark(
      id: data['id'] as String? ?? verseKey,
      verseKey: verseKey,
      chapterId: data['chapterId'] as int? ?? 1,
      chapterName: data['chapterName'] as String? ?? '',
      text: data['verseText'] as String? ?? '',
      timestamp: data['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      category: data['category'] as String? ?? 'general',
    );
    final updated = [...state.bookmarks, bookmark];
    state = state.copyWith(bookmarks: updated);
    _dataSource.saveBookmarks(updated);
  }

  void importNote(Map<String, dynamic> data) {
    final verseKey = data['verseKey'] as String? ?? '';
    // Skip duplicates
    if (state.notes.any((n) => n.verseKey == verseKey)) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final note = VerseNote(
      id: data['id'] as String? ?? _uuid.v4(),
      verseKey: verseKey,
      chapterId: data['chapterId'] as int? ?? 1,
      chapterName: data['chapterName'] as String? ?? '',
      verseText: data['verseText'] as String? ?? '',
      note: data['note'] as String? ?? '',
      createdAt: data['createdAt'] as int? ?? now,
      updatedAt: data['updatedAt'] as int? ?? now,
    );
    final updated = [...state.notes, note];
    state = state.copyWith(notes: updated);
    _dataSource.saveNotes(updated);
  }
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  return BookmarkNotifier(ref.watch(bookmarkLocalDataSourceProvider));
});
