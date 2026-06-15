import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/data/datasources/local/news_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/news_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/data/repositories/news_repository.dart';

class MockNewsLocalDs extends Mock implements NewsLocalDs {}

class MockNewsRemoteDs extends Mock implements NewsRemoteDs {}

void main() {
  late MockNewsLocalDs mockLocal;
  late MockNewsRemoteDs mockRemote;
  late NewsRepository repository;

  final testPost = NewsPost(
    slug: 'eid-al-fitr',
    title: 'Eid Al Fitr',
    date: DateTime(2025, 9, 29, 23, 29),
    excerpt: 'Imorgon blir det Eid al-Fitr...',
  );

  final testPostWithBody = NewsPost(
    slug: 'eid-al-fitr',
    title: 'Eid Al Fitr',
    date: DateTime(2025, 9, 29, 23, 29),
    excerpt: 'Imorgon blir det Eid al-Fitr...',
    body: '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr.',
  );

  setUpAll(() {
    registerFallbackValue(testPost);
  });

  setUp(() {
    mockLocal = MockNewsLocalDs();
    mockRemote = MockNewsRemoteDs();
    repository = NewsRepository(local: mockLocal, remote: mockRemote);
  });

  group('getCachedNews', () {
    test('returns cached news list when available', () {
      when(() => mockLocal.getCachedNews()).thenReturn([testPost]);

      final result = repository.getCachedNews();

      expect(result, [testPost]);
      verify(() => mockLocal.getCachedNews()).called(1);
      verifyNever(() => mockRemote.getNewsPosts());
    });

    test('returns null when no cache exists', () {
      when(() => mockLocal.getCachedNews()).thenReturn(null);

      final result = repository.getCachedNews();

      expect(result, isNull);
    });
  });

  group('refreshNews', () {
    test('fetches from remote, caches, and returns list', () async {
      when(() => mockRemote.getNewsPosts()).thenAnswer((_) async => [testPost]);
      when(() => mockLocal.cacheNews([testPost])).thenAnswer((_) async {});

      final result = await repository.refreshNews();

      expect(result, [testPost]);
      verify(() => mockRemote.getNewsPosts()).called(1);
      verify(() => mockLocal.cacheNews([testPost])).called(1);
    });

    test('returns cached list when remote fails', () async {
      when(() => mockRemote.getNewsPosts())
          .thenAnswer((_) async => throw const NetworkException());
      when(() => mockLocal.getCachedNews()).thenReturn([testPost]);

      final result = await repository.refreshNews();

      expect(result, [testPost]);
      verify(() => mockRemote.getNewsPosts()).called(1);
      verify(() => mockLocal.getCachedNews()).called(1);
      verifyNever(() => mockLocal.cacheNews(any()));
    });

    test('returns cached list when remote throws ParseException', () async {
      when(() => mockRemote.getNewsPosts())
          .thenAnswer((_) async => throw const ParseException());
      when(() => mockLocal.getCachedNews()).thenReturn([testPost]);

      final result = await repository.refreshNews();

      expect(result, [testPost]);
    });

    test('rethrows when remote fails and no cache exists', () async {
      when(() => mockRemote.getNewsPosts())
          .thenAnswer((_) async => throw const NetworkException());
      when(() => mockLocal.getCachedNews()).thenReturn(null);

      expect(
        () => repository.refreshNews(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getNewsBody', () {
    test('returns cached body when available', () async {
      when(() => mockLocal.getCachedArticle('eid-al-fitr'))
          .thenReturn('**Eid Mubarak!**');

      final result = await repository.getNewsBody('eid-al-fitr');

      expect(result, '**Eid Mubarak!**');
      verifyNever(() => mockRemote.getNewsPost(any()));
    });

    test('fetches from remote when no cached body', () async {
      when(() => mockLocal.getCachedArticle('eid-al-fitr')).thenReturn(null);
      when(() => mockRemote.getNewsPost('eid-al-fitr'))
          .thenAnswer((_) async => testPostWithBody);
      when(() => mockLocal.cacheArticle('eid-al-fitr', testPostWithBody.body!))
          .thenAnswer((_) async {});

      final result = await repository.getNewsBody('eid-al-fitr');

      expect(result, '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr.');
      verify(() => mockRemote.getNewsPost('eid-al-fitr')).called(1);
      verify(() => mockLocal.cacheArticle('eid-al-fitr', any())).called(1);
    });

    test('returns null when remote fails and no cached body', () async {
      when(() => mockLocal.getCachedArticle('eid-al-fitr')).thenReturn(null);
      when(() => mockRemote.getNewsPost('eid-al-fitr'))
          .thenAnswer((_) async => throw const NetworkException());

      final result = await repository.getNewsBody('eid-al-fitr');

      expect(result, isNull);
    });

    test('does not cache when remote returns post with null body', () async {
      when(() => mockLocal.getCachedArticle('eid-al-fitr')).thenReturn(null);
      when(() => mockRemote.getNewsPost('eid-al-fitr'))
          .thenAnswer((_) async => testPost);

      final result = await repository.getNewsBody('eid-al-fitr');

      expect(result, isNull);
      verifyNever(() => mockLocal.cacheArticle(any(), any()));
    });
  });

  group('getLastUpdated', () {
    test('returns last updated from local', () {
      when(() => mockLocal.getLastUpdated()).thenReturn('2026-06-15T10:00:00.000');

      final result = repository.getLastUpdated();

      expect(result, '2026-06-15T10:00:00.000');
    });

    test('returns null when never updated', () {
      when(() => mockLocal.getLastUpdated()).thenReturn(null);

      final result = repository.getLastUpdated();

      expect(result, isNull);
    });
  });
}
