import 'dart:developer' as dev;

/// Lightweight logger using dart:developer for filtered log output.
/// Each class gets a tag for easy filtering in DevTools.
class AppLogger {
  final String _tag;

  const AppLogger(this._tag);

  void debug(String message) {
    dev.log(message, name: _tag, level: 500);
  }

  void info(String message) {
    dev.log(message, name: _tag, level: 800);
  }

  void warning(String message) {
    dev.log('WARNING: $message', name: _tag, level: 900);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    dev.log(
      'ERROR: $message',
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
