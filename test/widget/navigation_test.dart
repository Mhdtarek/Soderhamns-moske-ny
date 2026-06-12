import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/app.dart';

void main() {
  group('Navigation', () {
    testWidgets('app starts on home screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hem'), findsWidgets);
    });

    testWidgets('bottom navigation bar is visible', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Hem'), findsWidgets);
      expect(find.text('Bönetider'), findsWidgets);
      expect(find.text('Nyheter'), findsWidgets);
      expect(find.text('Mer'), findsWidgets);
    });

    testWidgets('can navigate to Bönetider tab', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Bönetider').last);
      await tester.pumpAndSettle();

      expect(find.text('Igår'), findsOneWidget);
      expect(find.text('Idag'), findsOneWidget);
      expect(find.text('Imorgon'), findsOneWidget);
    });

    testWidgets('can navigate to Nyheter tab', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Nyheter').last);
      await tester.pumpAndSettle();

      expect(find.text('Nyheter'), findsWidgets);
    });

    testWidgets('can navigate to Mer tab', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Mer').last);
      await tester.pumpAndSettle();

      expect(find.text('Donera'), findsOneWidget);
      expect(find.text('Kontakt'), findsOneWidget);
      expect(find.text('Inställningar'), findsOneWidget);
      expect(find.text('Qibla'), findsOneWidget);
    });

    testWidgets('can navigate back to Hem tab', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Bönetider').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hem').last);
      await tester.pumpAndSettle();

      expect(find.text('Söderhamns Moské'), findsOneWidget);
    });
  });
}
