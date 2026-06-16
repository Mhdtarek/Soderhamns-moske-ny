import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/data/datasources/local/news_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/news_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/data/repositories/news_repository.dart';

class MockLocal extends Mock implements NewsLocalDs {}

class MockRemote extends Mock implements NewsRemoteDs {}

void main() {
  late MockLocal local;
  late MockRemote remote;
  late NewsRepository repo;

  final post = NewsPost(
    slug: 'test',
    title: 'Test',
    date: DateTime(2026, 6, 15),
    excerpt: 'Utdrag.',
  );

  setUpAll(() {
    registerFallbackValue(post);
  });

  setUp(() {
    local = MockLocal();
    remote = MockRemote();
    repo = NewsRepository(local: local, remote: remote);
  });

  group('refreshNews — online', () {
    test('fetches from remote, caches, returns data', () async {
      when(() => remote.getNewsPosts()).thenAnswer((_) async => [post]);
      when(() => local.cacheNews([post])).thenAnswer((_) async {});

      final result = await repo.refreshNews();

      expect(result, [post]);
      verify(() => remote.getNewsPosts()).called(1);
      verify(() => local.cacheNews([post])).called(1);
    });
  });

  group('refreshNews — offline fallback', () {
    test('returns cached data when remote fails', () async {
      when(() => remote.getNewsPosts())
          .thenAnswer((_) async => throw const NetworkException());
      when(() => local.getCachedNews()).thenReturn([post]);

      final result = await repo.refreshNews();

      expect(result, [post]);
    });

    test('rethrows when remote fails and no cache', () async {
      when(() => remote.getNewsPosts())
          .thenAnswer((_) async => throw const NetworkException());
      when(() => local.getCachedNews()).thenReturn(null);

      expect(() => repo.refreshNews(), throwsA(isA<NetworkException>()));
    });
  });

  group('getNewsBody', () {
    final postWithBody = post.copyWith(body: 'the body');

    test('returns cached article with metadata when available', () async {
      when(() => local.getCachedArticle('test')).thenReturn('cached body');
      when(() => local.getCachedNews()).thenReturn([post]);

      final result = await repo.getNewsBody('test');

      expect(result.slug, 'test');
      expect(result.title, 'Test');
      expect(result.body, 'cached body');
      verifyNever(() => remote.getNewsPost(any()));
    });

    test('fetches from remote when no cached body', () async {
      when(() => local.getCachedArticle('test')).thenReturn(null);
      when(() => remote.getNewsPost('test'))
          .thenAnswer((_) async => postWithBody);

      final result = await repo.getNewsBody('test');

      expect(result.slug, 'test');
      expect(result.title, 'Test');
      expect(result.body, 'the body');
    });

    test('throws when remote fails and no cached body', () async {
      when(() => local.getCachedArticle('test')).thenReturn(null);
      when(() => remote.getNewsPost('test'))
          .thenAnswer((_) async => throw const NetworkException());

      expect(
        () => repo.getNewsBody('test'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('returns post with null body when article has no content', () async {
      when(() => local.getCachedArticle('test')).thenReturn(null);
      when(() => remote.getNewsPost('test'))
          .thenAnswer((_) async => post.copyWith(body: null));

      final result = await repo.getNewsBody('test');

      expect(result.body, isNull);
      expect(result.title, 'Test');
    });
  });
}
