import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/features/news/presentation/widgets/news_card.dart';

void main() {
  final post = NewsPost(
    slug: 'test',
    title: 'Test Titel',
    date: DateTime(2026, 6, 15),
    excerpt: 'Detta är ett testutdrag.',
  );

  group('NewsCard', () {
    testWidgets('renders title, date and excerpt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NewsCard(post: post))),
      );

      expect(find.text('Test Titel'), findsOneWidget);
      expect(find.text('Detta är ett testutdrag.'), findsOneWidget);
    });

    testWidgets('works without image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NewsCard(post: post))),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsCard(post: post, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      expect(tapped, isTrue);
    });

    testWidgets('handles empty excerpt', (tester) async {
      final noExcerpt = post.copyWith(excerpt: '');

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NewsCard(post: noExcerpt))),
      );

      expect(find.text('Test Titel'), findsOneWidget);
    });
  });
}
