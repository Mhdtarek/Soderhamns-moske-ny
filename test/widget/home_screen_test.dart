import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/app.dart';

void main() {
  testWidgets('HomeScreen renders AppBar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App()),
    );
    await tester.pump();

    expect(find.text('Söderhamns Moské'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('HomeScreen has Cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App()),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(Card), findsWidgets);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
