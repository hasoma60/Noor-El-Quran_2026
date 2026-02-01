import 'package:flutter_test/flutter_test.dart';
import 'package:noor_alquran/core/utils/arabic_utils.dart';
import 'package:noor_alquran/core/utils/html_sanitizer.dart';

void main() {
  group('Arabic Utils', () {
    test('toArabicNumeral converts numbers correctly', () {
      expect(toArabicNumeral(0), '٠');
      expect(toArabicNumeral(1), '١');
      expect(toArabicNumeral(114), '١١٤');
      expect(toArabicNumeral(255), '٢٥٥');
      expect(toArabicNumeral(6236), '٦٢٣٦');
    });

    test('relativeTimeArabic returns correct relative time', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(relativeTimeArabic(now), 'الآن');
      expect(relativeTimeArabic(now - 120000), contains('دقيقة'));
    });
  });

  group('HTML Sanitizer', () {
    test('stripHtml removes all tags', () {
      expect(stripHtml('<p>Hello</p>'), 'Hello');
      expect(stripHtml('<b>Bold</b> text'), 'Bold text');
    });

    test('sanitizeHtml removes script tags', () {
      expect(sanitizeHtml('<script>alert("xss")</script>text'), 'text');
    });

    test('sanitizeHtml removes javascript URLs', () {
      expect(sanitizeHtml('javascript:alert(1)'), contains('alert'));
      expect(sanitizeHtml('javascript:alert(1)').contains('javascript'), false);
    });
  });
}
