import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/search_result.dart';
import '../../../core/constants/app_constants.dart';
import 'chapters_provider.dart';

final quranSearchProvider =
    FutureProvider.family<List<SearchResult>, String>((ref, query) async {
  final trimmed = query.trim();
  if (trimmed.length < searchMinLength) return [];
  final repository = ref.watch(quranRepositoryProvider);
  return repository.search(trimmed);
});
