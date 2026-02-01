import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager for Quran audio files
/// Implements LRU eviction with long retention for offline access
class QuranAudioCacheManager {
  static const String key = 'quranAudioCache';
  
  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 500, // ~500 audio files (surahs + verses)
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  /// Get cached file or download if not available
  static Future<FileInfo?> getFile(String url) async {
    try {
      return await instance.getFileFromCache(url);
    } catch (e) {
      return null;
    }
  }

  /// Download and cache file
  static Future<FileInfo> downloadFile(String url) async {
    return await instance.downloadFile(url);
  }

  /// Check if file is cached
  static Future<bool> isCached(String url) async {
    final file = await getFile(url);
    return file != null;
  }

  /// Get cached file path or null
  static Future<String?> getCachedPath(String url) async {
    final file = await getFile(url);
    return file?.file.path;
  }

  /// Clear entire audio cache
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }

  /// Remove specific file from cache
  static Future<void> removeFile(String url) async {
    await instance.removeFile(url);
  }

  /// Get cache statistics
  static Future<int> getCacheSize() async {
    // Note: flutter_cache_manager doesn't expose size directly
    // This would need to be calculated from files
    return 0;
  }
}

/// Extension for easy use with audio URLs
extension AudioCacheExtension on String {
  Future<String> get cachedAudioPath async {
    final cached = await QuranAudioCacheManager.getCachedPath(this);
    if (cached != null) return cached;
    
    final downloaded = await QuranAudioCacheManager.downloadFile(this);
    return downloaded.file.path;
  }
  
  Future<bool> get isAudioCached => QuranAudioCacheManager.isCached(this);
}
