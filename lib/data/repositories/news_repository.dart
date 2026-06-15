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

  Future<String?> getNewsBody(String slug) async {
    final cached = local.getCachedArticle(slug);
    if (cached != null) return cached;

    try {
      final post = await remote.getNewsPost(slug);
      if (post.body != null) {
        await local.cacheArticle(slug, post.body!);
      }
      return post.body;
    } catch (_) {
      return null;
    }
  }

  String? getLastUpdated() {
    return local.getLastUpdated();
  }
}
