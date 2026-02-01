import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../data/datasources/remote/quran_remote_datasource.dart';
import '../../../domain/entities/chapter.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final quranRemoteDataSourceProvider = Provider<QuranRemoteDataSource>((ref) {
  return QuranRemoteDataSource(ref.watch(apiClientProvider));
});

final chaptersProvider = FutureProvider<List<Chapter>>((ref) async {
  final dataSource = ref.watch(quranRemoteDataSourceProvider);
  return dataSource.fetchChapters();
});
