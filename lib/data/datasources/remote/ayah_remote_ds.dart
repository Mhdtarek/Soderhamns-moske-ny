import 'package:dio/dio.dart';
import 'package:soderhamns_moske_app/core/config/env.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
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
      final editions = response.data['data'] as List<dynamic>;
      final Map<String, dynamic> arabic = editions[0] as Map<String, dynamic>;
      final Map<String, dynamic> swedish = editions[1] as Map<String, dynamic>;
      final surahData = arabic['surah'] as Map<String, dynamic>;

      return Ayah(
        number: number,
        surahNumber: surahData['number'] as int,
        surahName: surahData['name'] as String,
        surahEnglishName: surahData['englishName'] as String,
        numberInSurah: arabic['numberInSurah'] as int,
        arabicText: arabic['text'] as String,
        translation: swedish['text'] as String,
        dateKey: todayKey(),
      );
    } on DioException {
      throw const NetworkException();
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
