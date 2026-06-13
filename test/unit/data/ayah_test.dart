import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/data/models/ayah.dart';

void main() {
  const testAyah = Ayah(
    number: 1,
    surahNumber: 1,
    surahName: 'الفاتحة',
    surahEnglishName: 'Al-Faatiha',
    numberInSurah: 1,
    arabicText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
    translation: 'I GUDS, DEN NÅDERIKES, DEN BARMHÄRTIGES NAMN',
    dateKey: '2026-01-01',
  );

  group('Ayah', () {
    test('constructs with all fields', () {
      expect(testAyah.number, 1);
      expect(testAyah.surahNumber, 1);
      expect(testAyah.surahName, 'الفاتحة');
      expect(testAyah.surahEnglishName, 'Al-Faatiha');
      expect(testAyah.numberInSurah, 1);
      expect(testAyah.arabicText, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');
      expect(testAyah.translation, 'I GUDS, DEN NÅDERIKES, DEN BARMHÄRTIGES NAMN');
      expect(testAyah.dateKey, '2026-01-01');
    });

    test('fromJson parses API response correctly', () {
      final json = {
        'number': 1,
        'surahNumber': 1,
        'surahName': 'الفاتحة',
        'surahEnglishName': 'Al-Faatiha',
        'numberInSurah': 1,
        'arabicText': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        'translation': 'I GUDS, DEN NÅDERIKES, DEN BARMHÄRTIGES NAMN',
        'dateKey': '2026-01-01',
      };

      final ayah = Ayah.fromJson(json);

      expect(ayah.number, 1);
      expect(ayah.surahNumber, 1);
      expect(ayah.arabicText, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');
      expect(ayah.translation, 'I GUDS, DEN NÅDERIKES, DEN BARMHÄRTIGES NAMN');
      expect(ayah.dateKey, '2026-01-01');
    });

    test('fromJson handles different surahs', () {
      final json = {
        'number': 2,
        'surahNumber': 1,
        'surahName': 'الفاتحة',
        'surahEnglishName': 'Al-Faatiha',
        'numberInSurah': 2,
        'arabicText': 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
        'translation': 'LOV OCH PRIS TILLHÖR GUD, VÄRLDARNAS HERRE',
        'dateKey': '2026-01-02',
      };

      final ayah = Ayah.fromJson(json);

      expect(ayah.number, 2);
      expect(ayah.numberInSurah, 2);
    });

    test('toJson produces correct output', () {
      final json = testAyah.toJson();

      expect(json['number'], 1);
      expect(json['surahNumber'], 1);
      expect(json['surahName'], 'الفاتحة');
      expect(json['surahEnglishName'], 'Al-Faatiha');
      expect(json['arabicText'], 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');
      expect(json['translation'], 'I GUDS, DEN NÅDERIKES, DEN BARMHÄRTIGES NAMN');
      expect(json['dateKey'], '2026-01-01');
    });

    test('fromJson and toJson are symmetric', () {
      final original = {
        'number': 1,
        'surahNumber': 1,
        'surahName': 'الفاتحة',
        'surahEnglishName': 'Al-Faatiha',
        'numberInSurah': 1,
        'arabicText': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        'translation': 'I GUDS, DEN NÅDERIKES, DEN BARMHÄRTIGES NAMN',
        'dateKey': '2026-01-01',
      };

      final ayah = Ayah.fromJson(original);
      final json = ayah.toJson();

      expect(json, original);
    });

    test('equality works correctly', () {
      const a = Ayah(
        number: 1,
        surahNumber: 1,
        surahName: 'الفاتحة',
        surahEnglishName: 'Al-Faatiha',
        numberInSurah: 1,
        arabicText: 'بِسْمِ ٱللَّهِ',
        translation: 'I GUDS NAMN',
        dateKey: '2026-01-01',
      );

      const b = Ayah(
        number: 1,
        surahNumber: 1,
        surahName: 'الفاتحة',
        surahEnglishName: 'Al-Faatiha',
        numberInSurah: 1,
        arabicText: 'بِسْمِ ٱللَّهِ',
        translation: 'I GUDS NAMN',
        dateKey: '2026-01-01',
      );

      const c = Ayah(
        number: 2,
        surahNumber: 1,
        surahName: 'الفاتحة',
        surahEnglishName: 'Al-Faatiha',
        numberInSurah: 2,
        arabicText: 'ٱلْحَمْدُ',
        translation: 'LOV OCH PRIS',
        dateKey: '2026-01-02',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith creates modified copy', () {
      final modified = testAyah.copyWith(
        translation: 'Annan översättning',
        dateKey: '2026-06-13',
      );

      expect(modified.translation, 'Annan översättning');
      expect(modified.dateKey, '2026-06-13');
      expect(modified.number, testAyah.number);
      expect(modified.surahName, testAyah.surahName);
      expect(modified.arabicText, testAyah.arabicText);
    });
  });
}
