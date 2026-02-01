import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class _CacheEntry {
  final dynamic data;
  final int expiresAt;

  _CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiresAt;
}

class CacheService {
  final Map<String, _CacheEntry> _memoryCache = {};
  String? _cacheDir;

  Future<String> get _cacheDirPath async {
    if (_cacheDir != null) return _cacheDir!;
    final dir = await getApplicationCacheDirectory();
    _cacheDir = '${dir.path}/api_cache';
    await Directory(_cacheDir!).create(recursive: true);
    return _cacheDir!;
  }

  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^\w\-.]'), '_');
  }

  /// Get data from cache (memory first, then disk)
  Future<T?> get<T>(String key) async {
    // Level 1: Memory cache
    final memEntry = _memoryCache[key];
    if (memEntry != null && !memEntry.isExpired) {
      return memEntry.data as T;
    }
    if (memEntry != null && memEntry.isExpired) {
      _memoryCache.remove(key);
    }

    // Level 2: Disk cache
    try {
      final dir = await _cacheDirPath;
      final file = File('$dir/${_sanitizeKey(key)}.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final envelope = jsonDecode(content) as Map<String, dynamic>;
        final expiresAt = envelope['expiresAt'] as int;
        if (DateTime.now().millisecondsSinceEpoch <= expiresAt) {
          final data = envelope['data'];
          // Promote to memory cache
          _memoryCache[key] = _CacheEntry(data: data, expiresAt: expiresAt);
          return data as T;
        } else {
          // Expired disk cache - clean up
          await file.delete();
        }
      }
    } catch (_) {
      // Disk cache read failure is non-fatal
    }

    return null;
  }

  /// Put data into both memory and disk cache
  Future<void> put(String key, dynamic data, {int ttlMs = versesCacheTtl}) async {
    final expiresAt = DateTime.now().millisecondsSinceEpoch + ttlMs;

    // Level 1: Memory cache
    _memoryCache[key] = _CacheEntry(data: data, expiresAt: expiresAt);

    // Level 2: Disk cache
    try {
      final dir = await _cacheDirPath;
      final file = File('$dir/${_sanitizeKey(key)}.json');
      final envelope = jsonEncode({
        'expiresAt': expiresAt,
        'data': data,
      });
      await file.writeAsString(envelope);
    } catch (_) {
      // Disk cache write failure is non-fatal
    }
  }

  /// Remove a specific key from both caches
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    try {
      final dir = await _cacheDirPath;
      final file = File('$dir/${_sanitizeKey(key)}.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Clear all caches
  Future<void> clearAll() async {
    _memoryCache.clear();
    try {
      final dir = await _cacheDirPath;
      final cacheDir = Directory(dir);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }
    } catch (_) {}
  }

  /// Clear only expired entries from memory cache
  void clearExpired() {
    _memoryCache.removeWhere((_, entry) => entry.isExpired);
  }
}
