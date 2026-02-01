import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/bookmark.dart';
import '../../../domain/entities/verse_note.dart';

/// Local datasource for bookmarks and notes using SharedPreferences.
/// Will be migrated to Isar in a future iteration for better query support.
class BookmarkLocalDataSource {
  final SharedPreferences _prefs;

  BookmarkLocalDataSource(this._prefs);

  // ── Bookmarks ──

  List<Bookmark> getBookmarks() {
    final json = _prefs.getString('bookmarks');
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((b) => _bookmarkFromJson(b as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBookmarks(List<Bookmark> bookmarks) {
    final json = jsonEncode(bookmarks.map(_bookmarkToJson).toList());
    return _prefs.setString('bookmarks', json);
  }

  Bookmark _bookmarkFromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      verseKey: json['verseKey'] as String,
      chapterId: json['chapterId'] as int,
      chapterName: json['chapterName'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] as int,
      category: json['category'] as String? ?? 'general',
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> _bookmarkToJson(Bookmark b) {
    return {
      'id': b.id,
      'verseKey': b.verseKey,
      'chapterId': b.chapterId,
      'chapterName': b.chapterName,
      'text': b.text,
      'timestamp': b.timestamp,
      'category': b.category,
      'note': b.note,
    };
  }

  // ── Notes ──

  List<VerseNote> getNotes() {
    final json = _prefs.getString('notes');
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((n) => _noteFromJson(n as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotes(List<VerseNote> notes) {
    final json = jsonEncode(notes.map(_noteToJson).toList());
    return _prefs.setString('notes', json);
  }

  VerseNote _noteFromJson(Map<String, dynamic> json) {
    return VerseNote(
      id: json['id'] as String,
      verseKey: json['verseKey'] as String,
      chapterId: json['chapterId'] as int,
      chapterName: json['chapterName'] as String,
      verseText: json['verseText'] as String,
      note: json['note'] as String,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
    );
  }

  Map<String, dynamic> _noteToJson(VerseNote n) {
    return {
      'id': n.id,
      'verseKey': n.verseKey,
      'chapterId': n.chapterId,
      'chapterName': n.chapterName,
      'verseText': n.verseText,
      'note': n.note,
      'createdAt': n.createdAt,
      'updatedAt': n.updatedAt,
    };
  }
}
