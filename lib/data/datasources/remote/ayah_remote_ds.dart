import 'package:dio/dio.dart';
import 'package:soderhamns_moske_app/core/config/env.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart'
    show AppException, NetworkException, ParseException;
import 'package:soderhamns_moske_app/data/models/ayah.dart';

final _alquranDio = Dio(BaseOptions(
  baseUrl: Env.alquranApiBase,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
));

class AyahRemoteDs {
  Future<Ayah> getAyah(int number) async {
    try {
      final response = await _alquranDio.get(
        '/ayah/$number/editions/quran-uthmani,sv.bernstrom',
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ParseException('Expected Map for getAyah response');
      }
      final editions = data['data'];
      if (editions is! List || editions.length < 2) {
        throw const ParseException('Expected List with 2 editions for getAyah');
      }
      final arabic = editions[0];
      final swedish = editions[1];
      if (arabic is! Map<String, dynamic> || swedish is! Map<String, dynamic>) {
        throw const ParseException('Expected Map editions in getAyah');
      }
      final surah = arabic['surah'];
      if (surah is! Map<String, dynamic>) {
        throw const ParseException('Expected Map surah in getAyah');
      }

      final surahNumber = surah['number'];
      final surahName = surah['name'];
      final surahEnglishName = surah['englishName'];
      final numberInSurah = arabic['numberInSurah'];
      final arabicText = arabic['text'];
      final translation = swedish['text'];
      if (surahNumber is! int ||
          surahName is! String ||
          surahEnglishName is! String ||
          numberInSurah is! int ||
          arabicText is! String ||
          translation is! String) {
        throw const ParseException('Missing or wrong type in getAyah fields');
      }

      return Ayah(
        number: number,
        surahNumber: surahNumber,
        surahName: surahName,
        surahEnglishName: surahEnglishName,
        numberInSurah: numberInSurah,
        arabicText: arabicText,
        translation: translation,
        dateKey: todayKey(),
      );
    } on DioException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }

  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static int dailyAyahNumber() {
    final now = DateTime.now();
    final dayOfYear = _dayOfYear(now);
    return ((dayOfYear * 17 + now.year) % 6236) + 1;
  }

  static int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }
}
