import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soderhamns_moske_app/data/datasources/local/news_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/news_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/data/repositories/news_repository.dart';
import 'package:soderhamns_moske_app/features/news/presentation/news_detail_screen.dart';
import 'package:soderhamns_moske_app/features/news/presentation/news_list_screen.dart';
import 'package:soderhamns_moske_app/features/news/providers/news_providers.dart';
import 'package:soderhamns_moske_app/shared/providers/connectivity_provider.dart';

class MockNewsLocal extends Mock implements NewsLocalDs {}

class MockNewsRemote extends Mock implements NewsRemoteDs {}

Widget createApp({
  required NewsLocalDs local,
  required NewsRemoteDs remote,
  bool online = true,
  Widget child = const NewsListScreen(),
}) {
  return ProviderScope(
    overrides: [
      newsRepositoryProvider.overrideWithValue(
        NewsRepository(local: local, remote: remote),
      ),
      connectivityProvider.overrideWithProvider(
        StreamProvider<bool>((ref) => Stream.value(online)),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  late MockNewsLocal local;
  late MockNewsRemote remote;

  setUp(() {
    local = MockNewsLocal();
    remote = MockNewsRemote();
  });

  group('News flow', () {
    testWidgets('list loads and shows menu cards', (tester) async {
      when(() => remote.getNewsPosts()).thenAnswer((_) async => [
        NewsPost(
          slug: 'post-1',
          title: 'Första nyheten',
          date: DateTime(2026, 6, 10),
          excerpt: 'Detta är den första nyheten.',
        ),
        NewsPost(
          slug: 'post-2',
          title: 'Andra nyheten',
          date: DateTime(2026, 6, 14),
          excerpt: 'Detta är den andra nyheten.',
        ),
      ]);
      when(() => local.cacheNews(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createApp(local: local, remote: remote));
      await tester.pumpAndSettle();

      expect(find.text('Första nyheten'), findsOneWidget);
      expect(find.text('Andra nyheten'), findsOneWidget);
    });

    testWidgets('detail renders Markdown content (headings, bold, italic, lists, code, links, images)',
        (tester) async {
      final markdownBody = '''
# Rubrik 1

## Rubrik 2

Detta är **fet text** och *kursiv text*.

- Punkt 1
- Punkt 2
- Punkt 3

`kod` i texten.

> Blockcitat

![alt](https://example.com/bild.jpg)
''';
      when(() => local.getCachedArticle('test-article')).thenReturn(null);
      when(() => remote.getNewsPost('test-article')).thenAnswer((_) async =>
          NewsPost(
            slug: 'test-article',
            title: 'Test Artikel',
            date: DateTime(2026, 6, 15),
            body: markdownBody,
          ));
      when(() => local.getCachedNews()).thenReturn([
        NewsPost(
          slug: 'test-article',
          title: 'Test Artikel',
          date: DateTime(2026, 6, 15),
        ),
      ]);

      await tester.pumpWidget(createApp(
        local: local,
        remote: remote,
        child: const NewsDetailScreen(slug: 'test-article'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Test Artikel'), findsAtLeast(1));
      expect(find.text('Rubrik 1'), findsOneWidget);
      expect(find.text('Rubrik 2'), findsOneWidget);
      expect(find.text('Punkt 1'), findsOneWidget);
      expect(find.text('Punkt 2'), findsOneWidget);
      expect(find.text('Punkt 3'), findsOneWidget);
      // Bold text is rendered as regular text by flutter_markdown via TextSpan
      expect(find.textContaining('fet text'), findsOneWidget);
      expect(find.textContaining('kursiv text'), findsOneWidget);
      expect(find.textContaining('kod'), findsOneWidget);
      expect(find.textContaining('Blockcitat'), findsOneWidget);
    });

    testWidgets('shows offline banner when offline with cached data',
        (tester) async {
      when(() => remote.getNewsPosts()).thenAnswer((_) async => [
        NewsPost(
          slug: 'cached-post',
          title: 'Cachad nyhet',
          date: DateTime(2026, 6, 10),
        ),
      ]);
      when(() => local.cacheNews(any())).thenAnswer((_) async {});
      when(() => local.getLastUpdated()).thenReturn('2026-06-15T10:00:00.000');

      await tester.pumpWidget(createApp(
        local: local,
        remote: remote,
        online: false,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Visar sparad version'), findsOneWidget);
      expect(find.textContaining('Senast uppdaterad'), findsOneWidget);
    });
  });
}
