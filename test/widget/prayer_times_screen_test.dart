import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';
import 'package:soderhamns_moske_app/features/prayer_times/presentation/prayer_times_screen.dart';
import 'package:soderhamns_moske_app/features/prayer_times/providers/prayer_times_providers.dart';

void main() {
  const testDay = PrayerDay(
    date: 12,
    fajr: '02:25',
    shuruk: '03:28',
    dhohr: '12:56',
    asr: '17:39',
    maghrib: '22:26',
    isha: '23:23',
  );

  Widget buildTestWidget({
    required AsyncValue<PrayerDay> todayValue,
    required AsyncValue<PrayerDay> yesterdayValue,
    required AsyncValue<PrayerDay> tomorrowValue,
  }) {
    return ProviderScope(
      overrides: [
        todayPrayerTimesProvider.overrideWith((ref) async {
          return todayValue.when(
            data: (d) => d,
            loading: () => throw StateError('loading'),
            error: (e, s) => throw e,
          );
        }),
        yesterdayPrayerTimesProvider.overrideWith((ref) async {
          return yesterdayValue.when(
            data: (d) => d,
            loading: () => throw StateError('loading'),
            error: (e, s) => throw e,
          );
        }),
        tomorrowPrayerTimesProvider.overrideWith((ref) async {
          return tomorrowValue.when(
            data: (d) => d,
            loading: () => throw StateError('loading'),
            error: (e, s) => throw e,
          );
        }),
      ],
      child: const MaterialApp(
        home: PrayerTimesScreen(),
      ),
    );
  }

  group('PrayerTimesScreen', () {
    testWidgets('displays tab bar with three tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        todayValue: const AsyncValue.data(testDay),
        yesterdayValue: const AsyncValue.data(testDay),
        tomorrowValue: const AsyncValue.data(testDay),
      ));

      expect(find.text('Igår'), findsOneWidget);
      expect(find.text('Idag'), findsOneWidget);
      expect(find.text('Imorgon'), findsOneWidget);
    });

    testWidgets('displays Bönetider in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        todayValue: const AsyncValue.data(testDay),
        yesterdayValue: const AsyncValue.data(testDay),
        tomorrowValue: const AsyncValue.data(testDay),
      ));

      expect(find.text('Bönetider'), findsOneWidget);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        todayValue: const AsyncValue.loading(),
        yesterdayValue: const AsyncValue.data(testDay),
        tomorrowValue: const AsyncValue.data(testDay),
      ));

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error view when loading fails', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        todayValue: AsyncValue.error(Exception('test'), StackTrace.current),
        yesterdayValue: const AsyncValue.data(testDay),
        tomorrowValue: const AsyncValue.data(testDay),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Kunde inte ladda bönetider'), findsOneWidget);
      expect(find.text('Försök igen'), findsOneWidget);
    });

    testWidgets('displays prayer times when data loads', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        todayValue: const AsyncValue.data(testDay),
        yesterdayValue: const AsyncValue.data(testDay),
        tomorrowValue: const AsyncValue.data(testDay),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('02:25'), findsOneWidget);
      expect(find.text('Shuruk'), findsOneWidget);
      expect(find.text('03:28'), findsOneWidget);
      expect(find.text('Dhohr'), findsOneWidget);
      expect(find.text('12:56'), findsOneWidget);
      expect(find.text('Asr'), findsOneWidget);
      expect(find.text('17:39'), findsOneWidget);
      expect(find.text('Maghrib'), findsOneWidget);
      expect(find.text('22:26'), findsOneWidget);
      expect(find.text('Isha'), findsOneWidget);
      expect(find.text('23:23'), findsOneWidget);
    });

    testWidgets('can switch between tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        todayValue: const AsyncValue.data(testDay),
        yesterdayValue: const AsyncValue.data(testDay),
        tomorrowValue: const AsyncValue.data(testDay),
      ));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Imorgon'));
      await tester.pumpAndSettle();

      expect(find.text('Fajr'), findsOneWidget);
    });

    testWidgets('shows Månadsvis section', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        todayValue: const AsyncValue.data(testDay),
        yesterdayValue: const AsyncValue.data(testDay),
        tomorrowValue: const AsyncValue.data(testDay),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Månadsvis'), findsOneWidget);
    });
  });
}
