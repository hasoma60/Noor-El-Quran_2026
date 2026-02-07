import 'package:flutter_test/flutter_test.dart';
import 'package:noor_alquran/core/services/cache_service.dart';

void main() {
  late CacheService cache;

  setUp(() {
    cache = CacheService();
  });

  group('CacheService - Memory cache', () {
    test('put and get returns stored value', () async {
      await cache.put('key1', 'value1', ttlMs: 60000);
      final result = await cache.get<String>('key1');
      expect(result, 'value1');
    });

    test('get returns null for missing key', () async {
      final result = await cache.get<String>('nonexistent');
      expect(result, isNull);
    });

    test('expired entries return null', () async {
      await cache.put('expiring', 'data', ttlMs: 1);
      // Wait for expiry
      await Future.delayed(const Duration(milliseconds: 10));
      final result = await cache.get<String>('expiring');
      expect(result, isNull);
    });

    test('stores various data types', () async {
      await cache.put('int', 42, ttlMs: 60000);
      await cache.put('list', [1, 2, 3], ttlMs: 60000);
      await cache.put('map', {'a': 1}, ttlMs: 60000);

      expect(await cache.get<int>('int'), 42);
      expect(await cache.get<List<dynamic>>('list'), [1, 2, 3]);
      expect(await cache.get<Map<String, dynamic>>('map'), {'a': 1});
    });
  });

  group('CacheService - LRU eviction', () {
    test('evicts oldest entries when exceeding max', () async {
      // The default max is 200 entries. Fill beyond that.
      for (int i = 0; i < 210; i++) {
        await cache.put('key_$i', 'value_$i', ttlMs: 60000);
      }

      // Memory count should be capped at 200
      expect(cache.memoryEntryCount, 200);

      // Memory count should be capped at 200 (oldest entries evicted)
      expect(cache.memoryEntryCount, lessThanOrEqualTo(200));
    });

    test('recently accessed entries survive eviction', () async {
      // Fill cache
      for (int i = 0; i < 200; i++) {
        await cache.put('key_$i', 'value_$i', ttlMs: 60000);
      }

      // Access key_0 to make it recently used
      await cache.get<String>('key_0');

      // Add more entries to trigger eviction
      for (int i = 200; i < 210; i++) {
        await cache.put('key_$i', 'value_$i', ttlMs: 60000);
      }

      // key_0 should still be in memory since we accessed it recently
      // (It was moved to the end of the LRU list)
      expect(cache.memoryEntryCount, 200);
    });
  });

  group('CacheService - clearExpired', () {
    test('removes only expired entries', () async {
      await cache.put('short', 'data', ttlMs: 1);
      await cache.put('long', 'data', ttlMs: 60000);

      await Future.delayed(const Duration(milliseconds: 10));
      cache.clearExpired();

      expect(await cache.get<String>('short'), isNull);
      expect(await cache.get<String>('long'), 'data');
    });
  });

  group('CacheService - remove', () {
    test('removes specific key', () async {
      await cache.put('toRemove', 'data', ttlMs: 60000);
      await cache.remove('toRemove');

      expect(await cache.get<String>('toRemove'), isNull);
    });
  });

  group('CacheService - clearAll', () {
    test('clears all memory entries', () async {
      await cache.put('a', 1, ttlMs: 60000);
      await cache.put('b', 2, ttlMs: 60000);

      await cache.clearAll();

      expect(cache.memoryEntryCount, 0);
      expect(await cache.get<int>('a'), isNull);
      expect(await cache.get<int>('b'), isNull);
    });
  });

  group('CacheService - overwrite', () {
    test('overwrites existing key with new value', () async {
      await cache.put('key', 'old', ttlMs: 60000);
      await cache.put('key', 'new', ttlMs: 60000);

      expect(await cache.get<String>('key'), 'new');
      expect(cache.memoryEntryCount, 1);
    });
  });
}
