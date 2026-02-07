import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import 'app_logger.dart';

class _CacheEntry {
  final dynamic data;
  final int expiresAt;

  _CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiresAt;
}

class CacheService {
  static const _log = AppLogger('CacheService');
  static const int _maxMemoryEntries = 200;

  final Map<String, _CacheEntry> _memoryCache = {};
  final List<String> _accessOrder = []; // LRU tracking
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

  void _trackAccess(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  void _evictIfNeeded() {
    while (_memoryCache.length > _maxMemoryEntries && _accessOrder.isNotEmpty) {
      final oldest = _accessOrder.removeAt(0);
      _memoryCache.remove(oldest);
    }
  }

  /// Get data from cache (memory first, then disk)
  Future<T?> get<T>(String key) async {
    // Level 1: Memory cache
    final memEntry = _memoryCache[key];
    if (memEntry != null && !memEntry.isExpired) {
      _trackAccess(key);
      return memEntry.data as T;
    }
    if (memEntry != null && memEntry.isExpired) {
      _memoryCache.remove(key);
      _accessOrder.remove(key);
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
          _trackAccess(key);
          _evictIfNeeded();
          return data as T;
        } else {
          // Expired disk cache - clean up
          await file.delete();
        }
      }
    } catch (e) {
      _log.warning('Disk cache read failed for $key: $e');
    }

    return null;
  }

  /// Put data into both memory and disk cache
  Future<void> put(String key, dynamic data, {int ttlMs = versesCacheTtl}) async {
    final expiresAt = DateTime.now().millisecondsSinceEpoch + ttlMs;

    // Level 1: Memory cache with LRU eviction
    _memoryCache[key] = _CacheEntry(data: data, expiresAt: expiresAt);
    _trackAccess(key);
    _evictIfNeeded();

    // Level 2: Disk cache
    try {
      final dir = await _cacheDirPath;
      final file = File('$dir/${_sanitizeKey(key)}.json');
      final envelope = jsonEncode({
        'expiresAt': expiresAt,
        'data': data,
      });
      await file.writeAsString(envelope);
    } catch (e) {
      _log.warning('Disk cache write failed for $key: $e');
    }
  }

  /// Remove a specific key from both caches
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    _accessOrder.remove(key);
    try {
      final dir = await _cacheDirPath;
      final file = File('$dir/${_sanitizeKey(key)}.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      _log.warning('Disk cache remove failed for $key: $e');
    }
  }

  /// Clear all caches
  Future<void> clearAll() async {
    _memoryCache.clear();
    _accessOrder.clear();
    try {
      final dir = await _cacheDirPath;
      final cacheDir = Directory(dir);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }
    } catch (e) {
      _log.error('Failed to clear disk cache', e);
    }
  }

  /// Clear only expired entries from memory cache
  void clearExpired() {
    final expired = <String>[];
    _memoryCache.forEach((key, entry) {
      if (entry.isExpired) expired.add(key);
    });
    for (final key in expired) {
      _memoryCache.remove(key);
      _accessOrder.remove(key);
    }
  }

  /// Current number of entries in memory cache
  int get memoryEntryCount => _memoryCache.length;
}
