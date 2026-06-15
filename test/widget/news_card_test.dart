import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';
import 'package:soderhamns_moske_app/features/news/presentation/widgets/news_card.dart';

void main() {
  final testPost = NewsPost(
    slug: 'eid-al-fitr',
    title: 'Eid Al Fitr',
    date: DateTime(2025, 9, 29),
    excerpt: 'Imorgon blir det Eid al-Fitr i A-hallen.',
  );

  group('NewsCard', () {
    testWidgets('renders title, date and excerpt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsCard(post: testPost),
          ),
        ),
      );

      expect(find.text('Eid Al Fitr'), findsOneWidget);
      expect(find.text('Imorgon blir det Eid al-Fitr i A-hallen.'),
          findsOneWidget);
    });

    testWidgets('renders without image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsCard(post: testPost),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Eid Al Fitr'), findsOneWidget);
    });

    testWidgets('renders with image', (tester) async {
      final postWithImage = testPost.copyWith(
        imageUrl: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsCard(post: postWithImage),
          ),
        ),
      );

      expect(find.text('Eid Al Fitr'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles empty excerpt gracefully', (tester) async {
      final postNoExcerpt = testPost.copyWith(excerpt: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsCard(post: postNoExcerpt),
          ),
        ),
      );

      expect(find.text('Eid Al Fitr'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsCard(
              post: testPost,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      expect(tapped, isTrue);
    });
  });
}
