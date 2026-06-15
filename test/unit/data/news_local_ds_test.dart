import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soderhamns_moske_app/data/datasources/local/news_local_ds.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';

void main() {
  late NewsLocalDs ds;

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('hive_news_test_');
    Hive.init(dir.path);
    SharedPreferences.setMockInitialValues({});
    ds = NewsLocalDs();
    await ds.init();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('news_cache');
  });

  group('cacheNews / getCachedNews', () {
    test('roundtrips a list of news posts without body', () async {
      final posts = [
        NewsPost(
          slug: 'eid-al-fitr',
          title: 'Eid Al Fitr',
          date: DateTime(2025, 9, 29, 23, 29),
          excerpt: 'Imorgon blir det Eid al-Fitr...',
          body: '**Eid Mubarak!** Full body here.',
        ),
        NewsPost(
          slug: 'ramadan-2026',
          title: 'Ramadan 2026',
          date: DateTime(2026, 2, 17),
          excerpt: 'Ramadan börjar snart.',
          body: '# Ramadan\n\nVälkommen.',
        ),
      ];

      await ds.cacheNews(posts);
      final cached = ds.getCachedNews();

      expect(cached, isNotNull);
      expect(cached!.length, 2);
      expect(cached[0].slug, 'eid-al-fitr');
      expect(cached[0].title, 'Eid Al Fitr');
      expect(cached[0].date, DateTime(2025, 9, 29, 23, 29));
      expect(cached[0].excerpt, 'Imorgon blir det Eid al-Fitr...');
      expect(cached[0].body, isNull);
      expect(cached[1].slug, 'ramadan-2026');
      expect(cached[1].title, 'Ramadan 2026');
    });

    test('returns null when no news cached', () async {
      final cached = ds.getCachedNews();

      expect(cached, isNull);
    });

    test('returns null after cache is corrupted', () async {
      await ds.cacheNews([]);
      // Manually corrupt the box
      final box = await Hive.openBox<String>('news_cache');
      await box.put('news_list', 'not valid json');

      final cached = ds.getCachedNews();

      expect(cached, isNull);
    });
  });

  group('cacheArticle / getCachedArticle', () {
    test('roundtrips an article body by slug', () async {
      const body = '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr.';
      const slug = 'eid-al-fitr';

      await ds.cacheArticle(slug, body);
      final cached = ds.getCachedArticle(slug);

      expect(cached, body);
    });

    test('returns null for uncached slug', () async {
      final cached = ds.getCachedArticle('nonexistent');

      expect(cached, isNull);
    });

    test('multiple articles do not interfere', () async {
      await ds.cacheArticle('post-a', 'Body A');
      await ds.cacheArticle('post-b', 'Body B');

      expect(ds.getCachedArticle('post-a'), 'Body A');
      expect(ds.getCachedArticle('post-b'), 'Body B');
    });

    test('can cache and retrieve empty body', () async {
      await ds.cacheArticle('empty-body', '');

      final cached = ds.getCachedArticle('empty-body');

      expect(cached, '');
    });
  });

  group('getLastUpdated', () {
    test('returns null before any news is cached', () async {
      expect(ds.getLastUpdated(), isNull);
    });

    test('returns ISO datetime string after caching news', () async {
      await ds.cacheNews([]);

      final lastUpdated = ds.getLastUpdated();

      expect(lastUpdated, isNotNull);
      expect(
        () => DateTime.parse(lastUpdated!),
        returnsNormally,
      );
    });
  });
}
