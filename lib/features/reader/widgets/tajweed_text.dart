import 'package:flutter/material.dart';
import '../../../core/constants/theme_constants.dart';

/// Parses Quran.com tajweed HTML markup and renders colored TextSpans.
///
/// The API returns text like:
///   `<tajweed class="ghunnah">نّ</tajweed>بِسْمِ`
/// or sometimes:
///   `<span class="ham_wasl">ٱ</span>`
class TajweedText extends StatelessWidget {
  final String tajweedHtml;
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final Color defaultColor;

  const TajweedText({
    super.key,
    required this.tajweedHtml,
    required this.fontFamily,
    required this.fontSize,
    required this.lineHeight,
    required this.defaultColor,
  });

  @override
  Widget build(BuildContext context) {
    final spans = _parseTajweedSpans(tajweedHtml);
    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  List<InlineSpan> _parseTajweedSpans(String html) {
    final spans = <InlineSpan>[];
    // Match both <tajweed class="...">...</tajweed> and <span class="...">...</span>
    final regex = RegExp(r'<(?:tajweed|span)\s+class="([^"]*)"[^>]*>(.*?)</(?:tajweed|span)>');
    var lastEnd = 0;

    for (final match in regex.allMatches(html)) {
      // Add plain text before this match
      if (match.start > lastEnd) {
        final plainText = _stripRemainingTags(html.substring(lastEnd, match.start));
        if (plainText.isNotEmpty) {
          spans.add(TextSpan(
            text: plainText,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontSize,
              height: lineHeight,
              color: defaultColor,
            ),
          ));
        }
      }

      final cssClass = match.group(1) ?? '';
      final innerText = _stripRemainingTags(match.group(2) ?? '');
      final color = TajweedColors.colorMap[cssClass] ?? defaultColor;

      if (innerText.isNotEmpty) {
        spans.add(TextSpan(
          text: innerText,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            height: lineHeight,
            color: color,
          ),
        ));
      }

      lastEnd = match.end;
    }

    // Add remaining plain text
    if (lastEnd < html.length) {
      final plainText = _stripRemainingTags(html.substring(lastEnd));
      if (plainText.isNotEmpty) {
        spans.add(TextSpan(
          text: plainText,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            height: lineHeight,
            color: defaultColor,
          ),
        ));
      }
    }

    return spans;
  }

  /// Remove any remaining HTML tags that weren't matched by the regex.
  String _stripRemainingTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
