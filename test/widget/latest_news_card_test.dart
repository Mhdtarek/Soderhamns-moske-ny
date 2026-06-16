import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soderhamns_moske_app/data/datasources/local/news_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/news_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/data/repositories/news_repository.dart';
import 'package:soderhamns_moske_app/features/news/providers/news_providers.dart';

class MockLocal extends Mock implements NewsLocalDs {}

class MockRemote extends Mock implements NewsRemoteDs {}

Widget createTestApp({
  required NewsLocalDs local,
  required NewsRemoteDs remote,
}) {
  return ProviderScope(
    overrides: [
      newsRepositoryProvider.overrideWithValue(
        NewsRepository(local: local, remote: remote),
      ),
    ],
    child: const MaterialApp(
      home: _TestLatestNewsWidget(),
    ),
  );
}

class _TestLatestNewsWidget extends ConsumerWidget {
  const _TestLatestNewsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsListProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            newsAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Column(
                children: [
                  const Text('Kunde inte ladda nyheter'),
                  TextButton(
                    onPressed: () => ref.invalidate(newsListProvider),
                    child: const Text('Försök igen'),
                  ),
                ],
              ),
              data: (posts) {
                if (posts.isEmpty) return const SizedBox.shrink();

                final sorted = List<NewsPost>.from(posts)
                  ..sort((a, b) => b.date.compareTo(a.date));
                final latest = sorted.take(2).toList();

                return Card(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Text('Nyheter'),
                      ),
                      for (final post in latest)
                        _TestNewsRow(post: post),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: Text('Visa alla'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TestNewsRow extends StatelessWidget {
  const _TestNewsRow({required this.post});

  final NewsPost post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('news_row_${post.slug}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(child: Text(post.title)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

void main() {
  late MockLocal local;
  late MockRemote remote;

  setUp(() {
    local = MockLocal();
    remote = MockRemote();
  });

  testWidgets('shows loading state initially', (tester) async {
    final completer = Completer<List<NewsPost>>();
    when(() => remote.getNewsPosts()).thenAnswer((_) => completer.future);
    when(() => local.getCachedNews()).thenReturn(null);

    await tester.pumpWidget(createTestApp(local: local, remote: remote));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows article titles when data loads', (tester) async {
    when(() => remote.getNewsPosts()).thenAnswer((_) async => [
          NewsPost(
            slug: 'first',
            title: 'Första nyheten',
            date: DateTime(2026, 6, 15),
            excerpt: 'Excerpt 1',
          ),
          NewsPost(
            slug: 'second',
            title: 'Andra nyheten',
            date: DateTime(2026, 6, 10),
            excerpt: 'Excerpt 2',
          ),
        ]);
    when(() => local.cacheNews(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestApp(local: local, remote: remote));
    await tester.pumpAndSettle();

    expect(find.text('Första nyheten'), findsOneWidget);
    expect(find.text('Andra nyheten'), findsOneWidget);
  });

  testWidgets('shows error state with retry button', (tester) async {
    when(() => remote.getNewsPosts()).thenThrow(Exception('fail'));
    when(() => local.getCachedNews()).thenReturn(null);

    await tester.pumpWidget(createTestApp(local: local, remote: remote));
    await tester.pumpAndSettle();

    expect(find.text('Kunde inte ladda nyheter'), findsOneWidget);
    expect(find.text('Försök igen'), findsOneWidget);
  });

  testWidgets('retry invalidates and refetches', (tester) async {
    var calls = 0;
    when(() => remote.getNewsPosts()).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw Exception('fail');
      return [
        NewsPost(
          slug: 'recovered',
          title: 'Återhämtad nyhet',
          date: DateTime(2026, 6, 15),
        ),
      ];
    });
    when(() => local.getCachedNews()).thenReturn(null);
    when(() => local.cacheNews(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestApp(local: local, remote: remote));
    await tester.pumpAndSettle();

    expect(find.text('Försök igen'), findsOneWidget);

    await tester.tap(find.text('Försök igen'));
    await tester.pumpAndSettle();

    expect(find.text('Återhämtad nyhet'), findsOneWidget);
  });

  testWidgets('shows empty when no articles', (tester) async {
    when(() => remote.getNewsPosts()).thenAnswer((_) async => []);
    when(() => local.cacheNews(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestApp(local: local, remote: remote));
    await tester.pumpAndSettle();

    expect(find.text('Nyheter'), findsNothing);
  });

  testWidgets('shows at most 2 latest articles', (tester) async {
    when(() => remote.getNewsPosts()).thenAnswer((_) async => [
          NewsPost(
            slug: 'a',
            title: 'A',
            date: DateTime(2026, 6, 15),
          ),
          NewsPost(
            slug: 'b',
            title: 'B',
            date: DateTime(2026, 6, 14),
          ),
          NewsPost(
            slug: 'c',
            title: 'C',
            date: DateTime(2026, 6, 13),
          ),
        ]);
    when(() => local.cacheNews(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestApp(local: local, remote: remote));
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsNothing);
  });

  testWidgets('shows Visa alla link', (tester) async {
    when(() => remote.getNewsPosts()).thenAnswer((_) async => [
          NewsPost(
            slug: 'only',
            title: 'Enda nyheten',
            date: DateTime(2026, 6, 15),
          ),
        ]);
    when(() => local.cacheNews(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestApp(local: local, remote: remote));
    await tester.pumpAndSettle();

    expect(find.text('Visa alla'), findsOneWidget);
  });
}
