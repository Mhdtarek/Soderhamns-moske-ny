import 'package:dio/dio.dart';
import 'package:soderhamns_moske_app/core/network/dio_client.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';

class PrayerTimesRemoteDs {
  Future<List<PrayerDay>> getMonth(int month) async {
    try {
      final response = await dioClient.get(
        '/api/getMonthPrayerTimes',
        queryParameters: {'month': month},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => PrayerDay.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw const NetworkException();
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<PrayerDay> getToday() async {
    try {
      final response = await dioClient.get('/api/getTodayPrayerTimes');
      return PrayerDay.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw const NetworkException();
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<PrayerDay> getYesterday() async {
    try {
      final response = await dioClient.get('/api/getYesterdayPrayerTimes');
      return PrayerDay.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw const NetworkException();
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<PrayerDay> getTomorrow() async {
    try {
      final response = await dioClient.get('/api/getTommorowPrayerTimes');
      return PrayerDay.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw const NetworkException();
    } catch (_) {
      throw const ParseException();
    }
  }
}
