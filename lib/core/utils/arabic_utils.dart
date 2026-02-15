/// Converts Western Arabic numerals to Eastern Arabic numerals
String toArabicNumeral(int number) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number.toString().split('').map((d) {
    final digit = int.tryParse(d);
    return digit != null ? arabicDigits[digit] : d;
  }).join();
}

/// Returns a Quran-style ayah marker.
///
/// `native`: ۝١
/// `badge`: ﴿١﴾
String formatAyahMarker(int verseNumber, {String style = 'native'}) {
  final num = toArabicNumeral(verseNumber);
  if (style == 'badge') {
    return '\uFD3F$num\uFD3E';
  }
  return '\u06DD$num';
}

/// Formats a verse key like "2:255" to "البقرة ٢٥٥"
String formatVerseReference(String verseKey, {String? chapterName}) {
  final parts = verseKey.split(':');
  if (parts.length != 2) return verseKey;
  final verseNum = int.tryParse(parts[1]);
  if (verseNum == null) return verseKey;
  final prefix = chapterName ?? parts[0];
  return '$prefix:${toArabicNumeral(verseNum)}';
}

/// Returns relative time string in Arabic
String relativeTimeArabic(int timestamp) {
  final now = DateTime.now().millisecondsSinceEpoch;
  final diff = now - timestamp;
  final seconds = diff ~/ 1000;
  final minutes = seconds ~/ 60;
  final hours = minutes ~/ 60;
  final days = hours ~/ 24;

  if (seconds < 60) return 'الآن';
  if (minutes < 60) return 'منذ ${toArabicNumeral(minutes)} دقيقة';
  if (hours < 24) return 'منذ ${toArabicNumeral(hours)} ساعة';
  if (days < 30) return 'منذ ${toArabicNumeral(days)} يوم';
  final months = days ~/ 30;
  if (months < 12) return 'منذ ${toArabicNumeral(months)} شهر';
  final years = months ~/ 12;
  return 'منذ ${toArabicNumeral(years)} سنة';
}
