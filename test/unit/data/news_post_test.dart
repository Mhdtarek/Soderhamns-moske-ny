import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';

void main() {
  final testNewsPost = NewsPost(
    slug: 'eid-al-fitr',
    title: 'Eid Al Fitr',
    date: DateTime(2025, 9, 29, 23, 29),
    excerpt: 'Imorgon blir det Eid al-Fitr...',
    body: '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr i A-hallen...',
  );

  group('NewsPost', () {
    test('constructs with all fields', () {
      expect(testNewsPost.slug, 'eid-al-fitr');
      expect(testNewsPost.title, 'Eid Al Fitr');
      expect(testNewsPost.date, DateTime(2025, 9, 29, 23, 29));
      expect(testNewsPost.excerpt, 'Imorgon blir det Eid al-Fitr...');
      expect(testNewsPost.body, '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr i A-hallen...');
      expect(testNewsPost.imageUrl, isNull);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'slug': 'eid-al-fitr',
        'title': 'Eid Al Fitr',
        'date': '2025-09-29T23:29:00.000',
        'excerpt': 'Imorgon blir det Eid al-Fitr...',
        'body': '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr i A-hallen...',
      };

      final post = NewsPost.fromJson(json);

      expect(post.slug, 'eid-al-fitr');
      expect(post.title, 'Eid Al Fitr');
      expect(post.date, DateTime(2025, 9, 29, 23, 29));
      expect(post.excerpt, 'Imorgon blir det Eid al-Fitr...');
      expect(post.body, '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr i A-hallen...');
      expect(post.imageUrl, isNull);
    });

    test('fromJson handles optional imageUrl', () {
      final json = {
        'slug': 'sommarfest',
        'title': 'Sommarfest 2026',
        'date': '2026-06-15T18:00:00.000',
        'excerpt': 'Välkommen till sommarfest!',
        'imageUrl': 'https://example.com/fest.jpg',
      };

      final post = NewsPost.fromJson(json);

      expect(post.slug, 'sommarfest');
      expect(post.title, 'Sommarfest 2026');
      expect(post.date, DateTime(2026, 6, 15, 18, 0));
      expect(post.imageUrl, 'https://example.com/fest.jpg');
      expect(post.body, isNull);
    });

    test('fromJson handles missing excerpt defaulting to empty', () {
      final json = {
        'slug': 'test',
        'title': 'Test',
        'date': '2026-01-01T00:00:00.000',
      };

      final post = NewsPost.fromJson(json);

      expect(post.excerpt, '');
      expect(post.body, isNull);
      expect(post.imageUrl, isNull);
    });

    test('toJson produces correct output', () {
      final json = testNewsPost.toJson();

      expect(json['slug'], 'eid-al-fitr');
      expect(json['title'], 'Eid Al Fitr');
      expect(json['date'], '2025-09-29T23:29:00.000');
      expect(json['excerpt'], 'Imorgon blir det Eid al-Fitr...');
      expect(json['body'], '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr i A-hallen...');
      expect(json.containsKey('imageUrl'), true);
      expect(json['imageUrl'], null);
    });

    test('fromJson and toJson are symmetric', () {
      final original = {
        'slug': 'ramadan-2026',
        'title': 'Ramadan 2026',
        'date': '2026-02-17T00:00:00.000',
        'excerpt': 'Ramadan börjar...',
        'body': '# Ramadan\n\nVälkommen till Ramadan.',
        'imageUrl': 'https://example.com/ramadan.jpg',
      };

      final post = NewsPost.fromJson(original);
      final json = post.toJson();

      expect(json['slug'], original['slug']);
      expect(json['title'], original['title']);
      expect(json['excerpt'], original['excerpt']);
      expect(json['body'], original['body']);
      expect(json['imageUrl'], original['imageUrl']);
    });

    test('equality works correctly', () {
      final a = NewsPost(
        slug: 'post-1',
        title: 'Post 1',
        date: DateTime(2025, 9, 29, 23, 29),
        excerpt: 'Excerpt 1',
        body: 'Body 1',
      );

      final b = NewsPost(
        slug: 'post-1',
        title: 'Post 1',
        date: DateTime(2025, 9, 29, 23, 29),
        excerpt: 'Excerpt 1',
        body: 'Body 1',
      );

      final c = NewsPost(
        slug: 'post-2',
        title: 'Post 2',
        date: DateTime(2025, 9, 29, 23, 29),
        excerpt: 'Excerpt 2',
        body: 'Body 2',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith creates modified copy', () {
      final modified = testNewsPost.copyWith(
        title: 'Eid Al Fitr 2026',
        excerpt: 'Uppdaterad information...',
      );

      expect(modified.title, 'Eid Al Fitr 2026');
      expect(modified.excerpt, 'Uppdaterad information...');
      expect(modified.slug, testNewsPost.slug);
      expect(modified.date, testNewsPost.date);
      expect(modified.body, testNewsPost.body);
    });

    test('copyWith clears body when set to null', () {
      final withBody = testNewsPost.copyWith(body: 'Some body');
      expect(withBody.body, 'Some body');

      final withoutBody = withBody.copyWith(body: null);
      expect(withoutBody.body, isNull);
    });
  });
}
