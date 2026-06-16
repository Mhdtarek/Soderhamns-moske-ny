import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/data/datasources/local/news_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/news_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';

class NewsRepository {
  final NewsLocalDs local;
  final NewsRemoteDs remote;

  NewsRepository({required this.local, required this.remote});

  List<NewsPost>? getCachedNews() {
    return local.getCachedNews();
  }

  Future<List<NewsPost>> refreshNews() async {
    try {
      final posts = await remote.getNewsPosts();
      await local.cacheNews(posts);
      return posts;
    } catch (_) {
      final cached = local.getCachedNews();
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<NewsPost> getNewsBody(String slug) async {
    final cached = local.getCachedArticle(slug);
    if (cached != null) {
      final match = local.getCachedNews()?.where((p) => p.slug == slug).firstOrNull;
      if (match != null) {
        return match.copyWith(body: cached);
      }
    }

    final post = await remote.getNewsPost(slug);
    if (post.body != null) {
      try {
        await local.cacheArticle(slug, post.body!);
      } catch (_) {
        // Cache write failure is non-fatal
      }
    }
    return post;
  }

  String? getLastUpdated() {
    return local.getLastUpdated();
  }
}
