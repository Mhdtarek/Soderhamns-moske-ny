import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/news_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late NewsRemoteDs ds;

  setUp(() {
    mockDio = MockDio();
    ds = NewsRemoteDs(dio: mockDio);
  });

  group('getNewsPosts', () {
    test('returns list of NewsPost from API', () async {
      final apiResponse = [
        {
          'meta': {
            'title': 'Eid Al Fitr',
            'created': 'Admin',
            'date': '2025-09-29T23:29:00',
            'layout': 'nyheter',
          },
          'path': '/app/nyheter/eid-al-fitr',
          'excerpt': 'Imorgon blir det Eid al-Fitr...',
        },
        {
          'meta': {
            'title': 'Ramadan 2026',
            'created': 'Admin',
            'date': '2026-02-17T00:00:00',
            'layout': 'nyheter',
          },
          'path': '/app/nyheter/ramadan-2026',
          'excerpt': 'Ramadan börjar...',
          'imageUrl': 'https://example.com/ramadan.jpg',
        },
      ];

      when(() => mockDio.get('/api/getNewsPosts')).thenAnswer(
        (_) async => Response(
          data: apiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/getNewsPosts'),
        ),
      );

      final posts = await ds.getNewsPosts();

      expect(posts.length, 2);
      expect(posts[0].slug, 'eid-al-fitr');
      expect(posts[0].title, 'Eid Al Fitr');
      expect(posts[0].date, DateTime(2025, 9, 29, 23, 29));
      expect(posts[0].excerpt, 'Imorgon blir det Eid al-Fitr...');
      expect(posts[0].body, isNull);
      expect(posts[0].imageUrl, isNull);
      expect(posts[1].slug, 'ramadan-2026');
      expect(posts[1].title, 'Ramadan 2026');
      expect(posts[1].imageUrl, 'https://example.com/ramadan.jpg');
    });

    test('throws NetworkException on DioException', () async {
      when(() => mockDio.get('/api/getNewsPosts')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/getNewsPosts'),
        ),
      );

      expect(
        () => ds.getNewsPosts(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws ParseException on malformed response', () async {
      when(() => mockDio.get('/api/getNewsPosts')).thenAnswer(
        (_) async => Response(
          data: 'not a list',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/getNewsPosts'),
        ),
      );

      expect(
        () => ds.getNewsPosts(),
        throwsA(isA<ParseException>()),
      );
    });

    test('throws ParseException when meta field is missing', () async {
      final apiResponse = [
        {
          'path': '/app/nyheter/incomplete',
        },
      ];

      when(() => mockDio.get('/api/getNewsPosts')).thenAnswer(
        (_) async => Response(
          data: apiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/getNewsPosts'),
        ),
      );

      expect(
        () => ds.getNewsPosts(),
        throwsA(isA<ParseException>()),
      );
    });

    test('returns empty list when API returns empty array', () async {
      when(() => mockDio.get('/api/getNewsPosts')).thenAnswer(
        (_) async => Response(
          data: <dynamic>[],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/getNewsPosts'),
        ),
      );

      final posts = await ds.getNewsPosts();

      expect(posts, isEmpty);
    });
  });

  group('getNewsPost', () {
    test('returns single NewsPost with body from API', () async {
      final apiResponse = {
        'meta': {
          'title': 'Eid Al Fitr',
          'created': 'Admin',
          'date': '2025-09-29T23:29:00',
          'layout': 'nyheter',
        },
        'path': '/app/nyheter/eid-al-fitr',
        'body': '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr.',
      };

      when(() => mockDio.get('/api/getNewsPost/eid-al-fitr')).thenAnswer(
        (_) async => Response(
          data: apiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/api/getNewsPost/eid-al-fitr',
          ),
        ),
      );

      final post = await ds.getNewsPost('eid-al-fitr');

      expect(post.slug, 'eid-al-fitr');
      expect(post.title, 'Eid Al Fitr');
      expect(post.date, DateTime(2025, 9, 29, 23, 29));
      expect(post.body, '**Eid Mubarak!**\n\nImorgon blir det Eid al-Fitr.');
    });

    test('throws NetworkException on DioException', () async {
      when(() => mockDio.get('/api/getNewsPost/unknown')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/getNewsPost/unknown'),
        ),
      );

      expect(
        () => ds.getNewsPost('unknown'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws ParseException on malformed response', () async {
      when(() => mockDio.get('/api/getNewsPost/bad')).thenAnswer(
        (_) async => Response(
          data: 'not a map',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/getNewsPost/bad'),
        ),
      );

      expect(
        () => ds.getNewsPost('bad'),
        throwsA(isA<ParseException>()),
      );
    });

    test('throws ParseException when date field is missing', () async {
      final apiResponse = {
        'meta': {
          'title': 'No Date',
        },
        'path': '/app/nyheter/no-date',
      };

      when(() => mockDio.get('/api/getNewsPost/no-date')).thenAnswer(
        (_) async => Response(
          data: apiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/getNewsPost/no-date'),
        ),
      );

      expect(
        () => ds.getNewsPost('no-date'),
        throwsA(isA<ParseException>()),
      );
    });
  });
}
