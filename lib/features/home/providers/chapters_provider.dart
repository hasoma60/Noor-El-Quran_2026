import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/cache_service.dart';
import '../../../data/datasources/remote/quran_remote_datasource.dart';
import '../../../data/datasources/remote/alquran_cloud_datasource.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../../domain/entities/chapter.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

final quranRemoteDataSourceProvider = Provider<QuranRemoteDataSource>((ref) {
  return QuranRemoteDataSource(
    ref.watch(apiClientProvider),
    ref.watch(cacheServiceProvider),
  );
});

final alquranCloudDataSourceProvider = Provider<AlQuranCloudDataSource>((ref) {
  return AlQuranCloudDataSource();
});

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(
    ref.watch(quranRemoteDataSourceProvider),
    ref.watch(alquranCloudDataSourceProvider),
  );
});

final chaptersProvider = FutureProvider<List<Chapter>>((ref) async {
  final repository = ref.watch(quranRepositoryProvider);
  return repository.getChapters();
});
