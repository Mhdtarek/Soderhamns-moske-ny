import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/data/datasources/local/prayer_times_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/prayer_times_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';
import 'package:soderhamns_moske_app/data/repositories/prayer_times_repository.dart';

class MockPrayerTimesLocalDs extends Mock implements PrayerTimesLocalDs {}

class MockPrayerTimesRemoteDs extends Mock implements PrayerTimesRemoteDs {}

void main() {
  late MockPrayerTimesLocalDs mockLocal;
  late MockPrayerTimesRemoteDs mockRemote;
  late PrayerTimesRepository repository;

  const testDay = PrayerDay(
    date: 12,
    fajr: '02:25',
    shuruk: '03:28',
    dhohr: '12:56',
    asr: '17:39',
    maghrib: '22:26',
    isha: '23:23',
  );

  setUp(() {
    mockLocal = MockPrayerTimesLocalDs();
    mockRemote = MockPrayerTimesRemoteDs();
    repository = PrayerTimesRepository(local: mockLocal, remote: mockRemote);
  });

  group('getMonth', () {
    test('returns data from local datasource', () {
      final testData = [testDay];
      when(() => mockLocal.getMonth(6)).thenReturn(testData);

      final result = repository.getMonth(6);

      expect(result, testData);
      verify(() => mockLocal.getMonth(6)).called(1);
      verifyNever(() => mockRemote.getMonth(any()));
    });

    test('throws CacheException when local datasource throws', () {
      when(() => mockLocal.getMonth(6)).thenThrow(const CacheException());

      expect(() => repository.getMonth(6), throwsA(isA<CacheException>()));
    });

    test('returns empty list when month has no data', () {
      when(() => mockLocal.getMonth(2)).thenReturn([]);

      final result = repository.getMonth(2);

      expect(result, isEmpty);
    });
  });

  group('getToday', () {
    test('returns today prayer times from current month', () {
      final now = DateTime.now();
      final todayDay = testDay.copyWith(date: now.day);
      final otherDay = testDay.copyWith(date: now.day == 1 ? 2 : 1);
      
      when(() => mockLocal.getMonth(now.month)).thenReturn([otherDay, todayDay]);

      final result = repository.getToday();

      expect(result.date, now.day);
      verify(() => mockLocal.getMonth(now.month)).called(1);
    });

    test('throws CacheException when today not found in month data', () {
      final now = DateTime.now();
      final otherDay = testDay.copyWith(date: now.day == 1 ? 2 : 1);
      
      when(() => mockLocal.getMonth(now.month)).thenReturn([otherDay]);

      expect(() => repository.getToday(), throwsA(isA<CacheException>()));
    });

    test('throws CacheException when month data is empty', () {
      final now = DateTime.now();
      when(() => mockLocal.getMonth(now.month)).thenReturn([]);

      expect(() => repository.getToday(), throwsA(isA<CacheException>()));
    });
  });

  group('getYesterday', () {
    test('returns yesterday prayer times', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDay = testDay.copyWith(date: yesterday.day);
      
      when(() => mockLocal.getMonth(yesterday.month)).thenReturn([yesterdayDay]);

      final result = repository.getYesterday();

      expect(result.date, yesterday.day);
      verify(() => mockLocal.getMonth(yesterday.month)).called(1);
    });

    test('handles month boundary correctly', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDay = testDay.copyWith(date: yesterday.day);
      
      when(() => mockLocal.getMonth(yesterday.month)).thenReturn([yesterdayDay]);

      final result = repository.getYesterday();

      expect(result.date, yesterday.day);
    });

    test('throws CacheException when yesterday not found', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final otherDay = testDay.copyWith(date: yesterday.day == 1 ? 2 : 1);
      
      when(() => mockLocal.getMonth(yesterday.month)).thenReturn([otherDay]);

      expect(() => repository.getYesterday(), throwsA(isA<CacheException>()));
    });
  });

  group('getTomorrow', () {
    test('returns tomorrow prayer times', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDay = testDay.copyWith(date: tomorrow.day);
      
      when(() => mockLocal.getMonth(tomorrow.month)).thenReturn([tomorrowDay]);

      final result = repository.getTomorrow();

      expect(result.date, tomorrow.day);
      verify(() => mockLocal.getMonth(tomorrow.month)).called(1);
    });

    test('handles month boundary correctly', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDay = testDay.copyWith(date: tomorrow.day);
      
      when(() => mockLocal.getMonth(tomorrow.month)).thenReturn([tomorrowDay]);

      final result = repository.getTomorrow();

      expect(result.date, tomorrow.day);
    });

    test('throws CacheException when tomorrow not found', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final otherDay = testDay.copyWith(date: tomorrow.day == 1 ? 2 : 1);
      
      when(() => mockLocal.getMonth(tomorrow.month)).thenReturn([otherDay]);

      expect(() => repository.getTomorrow(), throwsA(isA<CacheException>()));
    });
  });

  group('syncFromRemote', () {
    test('downloads all 12 months and caches them', () async {
      final testData = [testDay];
      
      for (var month = 1; month <= 12; month++) {
        when(() => mockRemote.getMonth(month)).thenAnswer((_) async => testData);
        when(() => mockLocal.cacheMonth(month, testData)).thenAnswer((_) async {});
      }

      await repository.syncFromRemote();

      for (var month = 1; month <= 12; month++) {
        verify(() => mockRemote.getMonth(month)).called(1);
        verify(() => mockLocal.cacheMonth(month, testData)).called(1);
      }
    });

    test('throws NetworkException when remote fails', () async {
      when(() => mockRemote.getMonth(1)).thenThrow(const NetworkException());

      expect(
        () => repository.syncFromRemote(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws CacheException when local cache fails', () async {
      final testData = [testDay];
      when(() => mockRemote.getMonth(1)).thenAnswer((_) async => testData);
      when(() => mockLocal.cacheMonth(1, testData)).thenThrow(const CacheException());

      expect(
        () => repository.syncFromRemote(),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
