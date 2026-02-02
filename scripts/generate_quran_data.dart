// Script to fetch all Quran data (chapters, verses, translations, pages)
// and generate bundled JSON files for offline use.
//
// Usage: dart run scripts/generate_quran_data.dart
//
// Outputs:
//   - assets/data/quran_uthmani.json  (chapters + verses + translations)
//   - assets/data/quran_pages.json    (604 page mappings)

import 'dart:convert';
import 'dart:io';

const String quranApiBase = 'https://api.quran.com/api/v4';
const String alquranCloudBase = 'https://api.alquran.cloud/v1';

final HttpClient _client = HttpClient();

Future<Map<String, dynamic>> fetchJson(String url) async {
  final request = await _client.getUrl(Uri.parse(url));
  request.headers.set('Accept', 'application/json');
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  return jsonDecode(body) as Map<String, dynamic>;
}

Future<List<Map<String, dynamic>>> fetchChapters() async {
  stdout.write('Fetching chapters... ');
  final data = await fetchJson('$quranApiBase/chapters?language=ar');
  final chapters = (data['chapters'] as List<dynamic>).cast<Map<String, dynamic>>();
  stdout.writeln('OK (${chapters.length} chapters)');
  return chapters;
}

Future<List<Map<String, dynamic>>> fetchVersesForChapter(int chapterId) async {
  final data = await fetchJson(
    '$quranApiBase/verses/by_chapter/$chapterId'
    '?language=ar&words=false&translations=16'
    '&fields=text_uthmani,text_uthmani_tajweed'
    '&per_page=300',
  );
  return (data['verses'] as List<dynamic>).cast<Map<String, dynamic>>();
}

Future<List<Map<String, dynamic>>> fetchPageMappings() async {
  stdout.writeln('Fetching page mappings...');
  final pages = <Map<String, dynamic>>[];

  for (var page = 1; page <= 604; page++) {
    if (page % 50 == 0 || page == 1 || page == 604) {
      stdout.write('\r  Page $page/604');
    }
    try {
      final data = await fetchJson(
        '$quranApiBase/verses/by_page/$page?fields=verse_key&per_page=300',
      );
      final verses = (data['verses'] as List<dynamic>).cast<Map<String, dynamic>>();
      if (verses.isNotEmpty) {
        pages.add({
          'page': page,
          'start': verses.first['verse_key'],
          'end': verses.last['verse_key'],
        });
      }
    } catch (e) {
      stderr.writeln('\nWarning: Failed to fetch page $page: $e');
      // Use fallback: skip or add placeholder
    }
    // Rate limiting
    await Future.delayed(const Duration(milliseconds: 100));
  }
  stdout.writeln('\n  Done (${pages.length} pages)');
  return pages;
}

Future<void> main() async {
  stdout.writeln('=== Quran Data Generator ===\n');

  // 1. Fetch chapters
  final chapters = await fetchChapters();

  // 2. Fetch all verses chapter by chapter
  final allVerses = <int, List<Map<String, dynamic>>>{};
  for (final chapter in chapters) {
    final id = chapter['id'] as int;
    stdout.write('  Fetching chapter $id/114 (${chapter['name_simple']})... ');
    try {
      allVerses[id] = await fetchVersesForChapter(id);
      stdout.writeln('OK (${allVerses[id]!.length} verses)');
    } catch (e) {
      stderr.writeln('FAILED: $e');
      // Try AlQuran Cloud fallback
      stdout.write('    Trying fallback... ');
      try {
        final fallback = await fetchJson('$alquranCloudBase/surah/$id/ar.uthmani');
        final ayahs = (fallback['data']['ayahs'] as List<dynamic>).cast<Map<String, dynamic>>();
        allVerses[id] = ayahs.map((a) => {
          'id': a['number'] as int,
          'verse_key': '$id:${a['numberInSurah']}',
          'text_uthmani': a['text'] as String,
        }).toList();
        stdout.writeln('OK (fallback, ${allVerses[id]!.length} verses)');
      } catch (e2) {
        stderr.writeln('ALSO FAILED: $e2');
      }
    }
    // Rate limiting
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // 3. Build output JSON
  final output = {
    'generated_at': DateTime.now().toIso8601String(),
    'chapters': chapters,
    'verses': <String, dynamic>{},
  };

  for (final entry in allVerses.entries) {
    output['verses'] = (output['verses'] as Map<String, dynamic>)
      ..['${entry.key}'] = entry.value;
  }

  // 4. Write quran_uthmani.json
  final outFile = File('assets/data/quran_uthmani.json');
  final encoder = const JsonEncoder.withIndent(null); // compact
  await outFile.writeAsString(encoder.convert(output));
  final sizeKb = (await outFile.length()) / 1024;
  stdout.writeln('\nWrote ${outFile.path} (${sizeKb.toStringAsFixed(0)} KB)');

  // 5. Fetch and write page mappings
  final pages = await fetchPageMappings();
  final pagesFile = File('assets/data/quran_pages.json');
  await pagesFile.writeAsString(encoder.convert(pages));
  final pagesSizeKb = (await pagesFile.length()) / 1024;
  stdout.writeln('Wrote ${pagesFile.path} (${pagesSizeKb.toStringAsFixed(0)} KB)');

  stdout.writeln('\nDone!');
  _client.close();
}
