import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/data/models/next_prayer_countdown.dart';

void main() {
  const testCountdown = NextPrayerCountdown(
    currentPrayerName: 'Dhohr',
    nextPrayerName: 'Asr',
    nextPrayerTime: '17:39',
    remaining: Duration(hours: 2, minutes: 13, seconds: 45),
    isTomorrow: false,
    nextNextPrayerName: 'Maghrib',
    nextNextPrayerTime: '22:26',
  );

  group('NextPrayerCountdown', () {
    test('constructs with all fields', () {
      expect(testCountdown.currentPrayerName, 'Dhohr');
      expect(testCountdown.nextPrayerName, 'Asr');
      expect(testCountdown.nextPrayerTime, '17:39');
      expect(testCountdown.remaining, const Duration(hours: 2, minutes: 13, seconds: 45));
      expect(testCountdown.isTomorrow, false);
      expect(testCountdown.nextNextPrayerName, 'Maghrib');
      expect(testCountdown.nextNextPrayerTime, '22:26');
    });

    test('currentPrayerName can be null', () {
      const noCurrent = NextPrayerCountdown(
        currentPrayerName: null,
        nextPrayerName: 'Fajr',
        nextPrayerTime: '02:25',
        remaining: Duration(hours: 5),
        isTomorrow: false,
        nextNextPrayerName: 'Shuruk',
        nextNextPrayerTime: '03:28',
      );

      expect(noCurrent.currentPrayerName, isNull);
      expect(noCurrent.nextPrayerName, 'Fajr');
    });

    test('isTomorrow true for after-Isha edge case', () {
      const afterIsha = NextPrayerCountdown(
        currentPrayerName: 'Isha',
        nextPrayerName: 'Fajr',
        nextPrayerTime: '02:25',
        remaining: Duration(hours: 3, minutes: 2),
        isTomorrow: true,
        nextNextPrayerName: 'Shuruk',
        nextNextPrayerTime: '03:28',
      );

      expect(afterIsha.isTomorrow, true);
      expect(afterIsha.nextPrayerName, 'Fajr');
      expect(afterIsha.nextNextPrayerName, 'Shuruk');
    });

    test('equality works correctly', () {
      const a = NextPrayerCountdown(
        currentPrayerName: 'Dhohr',
        nextPrayerName: 'Asr',
        nextPrayerTime: '17:39',
        remaining: Duration(hours: 2),
        isTomorrow: false,
        nextNextPrayerName: 'Maghrib',
        nextNextPrayerTime: '22:26',
      );

      const b = NextPrayerCountdown(
        currentPrayerName: 'Dhohr',
        nextPrayerName: 'Asr',
        nextPrayerTime: '17:39',
        remaining: Duration(hours: 2),
        isTomorrow: false,
        nextNextPrayerName: 'Maghrib',
        nextNextPrayerTime: '22:26',
      );

      const c = NextPrayerCountdown(
        currentPrayerName: 'Fajr',
        nextPrayerName: 'Shuruk',
        nextPrayerTime: '03:28',
        remaining: Duration(minutes: 3),
        isTomorrow: false,
        nextNextPrayerName: 'Dhohr',
        nextNextPrayerTime: '12:56',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith creates modified copy', () {
      final modified = testCountdown.copyWith(
        nextPrayerName: 'Maghrib',
        remaining: const Duration(minutes: 30),
      );

      expect(modified.nextPrayerName, 'Maghrib');
      expect(modified.remaining, const Duration(minutes: 30));
      expect(modified.currentPrayerName, testCountdown.currentPrayerName);
      expect(modified.nextPrayerTime, testCountdown.nextPrayerTime);
      expect(modified.isTomorrow, testCountdown.isTomorrow);
      expect(modified.nextNextPrayerName, testCountdown.nextNextPrayerName);
    });
  });
}
