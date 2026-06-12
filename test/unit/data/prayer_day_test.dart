import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';

void main() {
  group('PrayerDay', () {
    test('fromJson parses API response with capitalized field names', () {
      final json = {
        'Dat': 12,
        'Fajr': '02:25',
        'Shuruk': '03:28',
        'Dhohr': '12:56',
        'Asr': '17:39',
        'Maghrib': '22:26',
        'Isha': '23:23',
      };

      final day = PrayerDay.fromJson(json);

      expect(day.date, 12);
      expect(day.fajr, '02:25');
      expect(day.shuruk, '03:28');
      expect(day.dhohr, '12:56');
      expect(day.asr, '17:39');
      expect(day.maghrib, '22:26');
      expect(day.isha, '23:23');
      expect(day.hijriDate, isNull);
      expect(day.gregorianLabel, isNull);
    });

    test('fromJson parses optional hijriDate and gregorianLabel', () {
      final json = {
        'Dat': 12,
        'Fajr': '02:25',
        'Shuruk': '03:28',
        'Dhohr': '12:56',
        'Asr': '17:39',
        'Maghrib': '22:26',
        'Isha': '23:23',
        'hijriDate': '26 Dhu al-Hijja 1447 e.h.',
        'gregorianLabel': '12 juni 2026',
      };

      final day = PrayerDay.fromJson(json);

      expect(day.hijriDate, '26 Dhu al-Hijja 1447 e.h.');
      expect(day.gregorianLabel, '12 juni 2026');
    });

    test('toJson produces correct output', () {
      const day = PrayerDay(
        date: 15,
        fajr: '06:05',
        shuruk: '08:44',
        dhohr: '12:06',
        asr: '13:05',
        maghrib: '15:18',
        isha: '17:40',
      );

      final json = day.toJson();

      expect(json['Dat'], 15);
      expect(json['Fajr'], '06:05');
      expect(json['Shuruk'], '08:44');
      expect(json['Dhohr'], '12:06');
      expect(json['Asr'], '13:05');
      expect(json['Maghrib'], '15:18');
      expect(json['Isha'], '17:40');
    });

    test('fromJson and toJson are symmetric', () {
      final original = {
        'Dat': 1,
        'Fajr': '06:13',
        'Shuruk': '09:00',
        'Dhohr': '12:00',
        'Asr': '12:45',
        'Maghrib': '14:50',
        'Isha': '17:20',
      };

      final day = PrayerDay.fromJson(original);
      final json = day.toJson();

      expect(json['Dat'], original['Dat']);
      expect(json['Fajr'], original['Fajr']);
      expect(json['Shuruk'], original['Shuruk']);
      expect(json['Dhohr'], original['Dhohr']);
      expect(json['Asr'], original['Asr']);
      expect(json['Maghrib'], original['Maghrib']);
      expect(json['Isha'], original['Isha']);
    });

    test('equality works correctly', () {
      const day1 = PrayerDay(
        date: 1,
        fajr: '06:13',
        shuruk: '09:00',
        dhohr: '12:00',
        asr: '12:45',
        maghrib: '14:50',
        isha: '17:20',
      );

      const day2 = PrayerDay(
        date: 1,
        fajr: '06:13',
        shuruk: '09:00',
        dhohr: '12:00',
        asr: '12:45',
        maghrib: '14:50',
        isha: '17:20',
      );

      const day3 = PrayerDay(
        date: 2,
        fajr: '06:13',
        shuruk: '09:00',
        dhohr: '12:00',
        asr: '12:46',
        maghrib: '14:51',
        isha: '17:21',
      );

      expect(day1, equals(day2));
      expect(day1, isNot(equals(day3)));
    });

    test('copyWith creates modified copy', () {
      const original = PrayerDay(
        date: 1,
        fajr: '06:13',
        shuruk: '09:00',
        dhohr: '12:00',
        asr: '12:45',
        maghrib: '14:50',
        isha: '17:20',
      );

      final modified = original.copyWith(fajr: '06:15');

      expect(modified.fajr, '06:15');
      expect(modified.date, original.date);
      expect(modified.dhohr, original.dhohr);
    });
  });
}
