/// Sanitize HTML content from tafsir API responses.
/// Allows basic formatting tags but strips potentially harmful content.
String sanitizeHtml(String html) {
  // Remove script tags and their content
  final scriptRegex = RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false);
  var sanitized = html.replaceAll(scriptRegex, '');

  // Remove style tags and their content
  final styleRegex = RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false);
  sanitized = sanitized.replaceAll(styleRegex, '');

  // Remove event handlers (on* attributes)
  final eventRegex = RegExp(r"""\s+on\w+\s*=\s*["'][^"']*["']""", caseSensitive: false);
  sanitized = sanitized.replaceAll(eventRegex, '');

  // Remove javascript: URLs
  final jsUrlRegex = RegExp(r'javascript\s*:', caseSensitive: false);
  sanitized = sanitized.replaceAll(jsUrlRegex, '');

  return sanitized.trim();
}

/// Strip all HTML tags and return plain text
String stripHtml(String html) {
  final tagRegex = RegExp(r'<[^>]*>');
  return html.replaceAll(tagRegex, '').trim();
}
