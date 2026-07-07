import 'package:dio/dio.dart';
import 'package:soderhamns_moske_app/core/network/dio_client.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart'
    show AppException, NetworkException, ParseException;
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';

class PrayerTimesRemoteDs {
  Future<List<PrayerDay>> getMonth(int month) async {
    try {
      final response = await dioClient.get(
        '/api/getMonthPrayerTimes',
        queryParameters: {'month': month},
      );
      final data = response.data;
      if (data is! List) throw const ParseException('Expected List for getMonth');
      return data
          .map((e) {
            if (e is! Map<String, dynamic>) {
              throw const ParseException('Expected Map in getMonth list');
            }
            return PrayerDay.fromJson(e);
          })
          .toList();
    } on DioException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<PrayerDay> getToday() async {
    try {
      final response = await dioClient.get('/api/getTodayPrayerTimes');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ParseException('Expected Map for getToday');
      }
      return PrayerDay.fromJson(data);
    } on DioException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<PrayerDay> getYesterday() async {
    try {
      final response = await dioClient.get('/api/getYesterdayPrayerTimes');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ParseException('Expected Map for getYesterday');
      }
      return PrayerDay.fromJson(data);
    } on DioException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<PrayerDay> getTomorrow() async {
    try {
      final response = await dioClient.get('/api/getTommorowPrayerTimes');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ParseException('Expected Map for getTomorrow');
      }
      return PrayerDay.fromJson(data);
    } on DioException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<int> getYear() async {
    try {
      final response = await dioClient.get('/api/getYear');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ParseException('Expected Map for getYear');
      }
      final year = data['Year'];
      if (year is! int) throw const ParseException('Expected int Year in getYear');
      return year;
    } on DioException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }
}
