import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';

class NewsLocalDs {
  static const _boxName = 'news_cache';
  static const _listKey = 'news_list';
  static const _lastUpdatedKey = 'news_last_updated';

  late Box<String> _box;
  late SharedPreferences _prefs;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> cacheNews(List<NewsPost> posts) async {
    final listWithNoBody = posts
        .map((p) => p.copyWith(body: null).toJson())
        .toList();
    final raw = jsonEncode(listWithNoBody);
    await _box.put(_listKey, raw);
    await _prefs.setString(
      _lastUpdatedKey,
      DateTime.now().toIso8601String(),
    );
  }

  List<NewsPost>? getCachedNews() {
    final raw = _box.get(_listKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => NewsPost.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheArticle(String slug, String body) async {
    await _box.put('article_body_$slug', body);
  }

  String? getCachedArticle(String slug) {
    return _box.get('article_body_$slug');
  }

  String? getLastUpdated() {
    return _prefs.getString(_lastUpdatedKey);
  }
}
