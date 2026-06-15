import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soderhamns_moske_app/data/datasources/local/news_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/news_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/data/repositories/news_repository.dart';
import 'package:soderhamns_moske_app/features/news/presentation/news_list_screen.dart';
import 'package:soderhamns_moske_app/features/news/providers/news_providers.dart';
import 'package:soderhamns_moske_app/shared/providers/connectivity_provider.dart';

class MockNewsLocalDs extends Mock implements NewsLocalDs {}

class MockNewsRemoteDs extends Mock implements NewsRemoteDs {}

void main() {
  late MockNewsLocalDs mockLocal;
  late MockNewsRemoteDs mockRemote;

  final testPosts = [
    NewsPost(
      slug: 'post-2',
      title: 'Nyhet 2',
      date: DateTime(2026, 6, 14),
      excerpt: 'Detta är den andra nyheten.',
    ),
    NewsPost(
      slug: 'post-1',
      title: 'Nyhet 1',
      date: DateTime(2026, 6, 10),
      excerpt: 'Detta är den första nyheten.',
    ),
  ];

  setUp(() {
    mockLocal = MockNewsLocalDs();
    mockRemote = MockNewsRemoteDs();
  });

  Widget createTestApp({bool online = true}) {
    return ProviderScope(
      overrides: [
        newsRepositoryProvider.overrideWithValue(
          NewsRepository(local: mockLocal, remote: mockRemote),
        ),
        connectivityProvider.overrideWithProvider(
          StreamProvider<bool>((ref) => Stream.value(online)),
        ),
      ],
      child: MaterialApp(
        home: NewsListScreen(),
      ),
    );
  }

  group('NewsListScreen', () {
    testWidgets('shows news cards when data loads', (tester) async {
      when(() => mockRemote.getNewsPosts())
          .thenAnswer((_) async => testPosts);
      when(() => mockLocal.cacheNews(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Nyhet 1'), findsOneWidget);
      expect(find.text('Nyhet 2'), findsOneWidget);
    });

    testWidgets('shows error view when network fails and no cache',
        (tester) async {
      when(() => mockRemote.getNewsPosts()).thenThrow(Exception('fail'));
      when(() => mockLocal.getCachedNews()).thenReturn(null);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows empty state when no posts exist', (tester) async {
      when(() => mockRemote.getNewsPosts()).thenAnswer((_) async => []);
      when(() => mockLocal.cacheNews(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Inga nyheter än'), findsOneWidget);
    });

    testWidgets('shows offline banner and cached data when offline',
        (tester) async {
      when(() => mockRemote.getNewsPosts())
          .thenAnswer((_) async => testPosts);
      when(() => mockLocal.cacheNews(any())).thenAnswer((_) async {});
      when(() => mockLocal.getLastUpdated())
          .thenReturn('2026-06-15T10:00:00.000');

      await tester.pumpWidget(createTestApp(online: false));
      await tester.pumpAndSettle();

      expect(find.text('Visar sparad version'), findsOneWidget);
      expect(find.textContaining('Senast uppdaterad'), findsOneWidget);
      expect(find.text('Nyhet 1'), findsOneWidget);
      expect(find.text('Nyhet 2'), findsOneWidget);
    });

    testWidgets('shows error view when offline with no cache',
        (tester) async {
      when(() => mockRemote.getNewsPosts()).thenThrow(Exception('fail'));
      when(() => mockLocal.getCachedNews()).thenReturn(null);

      await tester.pumpWidget(createTestApp(online: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
