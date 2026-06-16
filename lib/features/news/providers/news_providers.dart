import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/data/datasources/local/news_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/news_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/data/repositories/news_repository.dart';

final newsLocalDsProvider = Provider<NewsLocalDs>((ref) {
  return NewsLocalDs();
});

final newsRemoteDsProvider = Provider<NewsRemoteDs>((ref) {
  return NewsRemoteDs();
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository(
    local: ref.watch(newsLocalDsProvider),
    remote: ref.watch(newsRemoteDsProvider),
  );
});

final newsListProvider = FutureProvider<List<NewsPost>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  try {
    return await repo.refreshNews();
  } catch (_) {
    final cached = repo.getCachedNews();
    if (cached != null) return cached;
    rethrow;
  }
});

final newsDetailProvider =
    FutureProvider.family<NewsPost?, String>((ref, slug) async {
  final repo = ref.watch(newsRepositoryProvider);

  try {
    return await repo.getNewsBody(slug);
  } on NetworkException {
    throw const NetworkException();
  } on ParseException {
    throw const ParseException();
  } catch (_) {
    final cached = repo.getCachedNews()
        ?.where((p) => p.slug == slug)
        .firstOrNull;
    if (cached != null) return cached;
    rethrow;
  }
});
