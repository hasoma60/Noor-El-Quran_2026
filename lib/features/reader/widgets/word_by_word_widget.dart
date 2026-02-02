import 'package:flutter/material.dart';
import '../../../domain/entities/verse.dart';

/// Displays each word of a verse with its translation underneath.
/// Uses a Wrap widget with RTL direction for natural Arabic flow.
class WordByWordWidget extends StatelessWidget {
  final List<Word> words;
  final String fontFamily;
  final double fontSize;
  final Color textColor;
  final Color translationColor;

  const WordByWordWidget({
    super.key,
    required this.words,
    required this.fontFamily,
    required this.fontSize,
    required this.textColor,
    required this.translationColor,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: words.map((word) {
          return IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  word.textUthmani,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: fontSize,
                    height: 1.6,
                    color: textColor,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 2),
                Text(
                  word.translationText,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: translationColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
