import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';

class PrayerTimesLocalDs {
  static const _boxName = 'prayer_times';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> loadFromAssets() async {
    for (var month = 1; month <= 12; month++) {
      final key = 'month_$month';
      if (_box.containsKey(key)) continue;
      try {
        final raw = await rootBundle.loadString('assets/prayer_times/$month.json');
        await _box.put(key, raw);
      } catch (_) {
        // Asset not found, skip
      }
    }
  }

  List<PrayerDay> getMonth(int month) {
    final raw = _box.get('month_$month');
    if (raw == null) throw const CacheException();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PrayerDay.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<void> cacheMonth(int month, List<PrayerDay> data) async {
    final raw = jsonEncode(data.map((d) => d.toJson()).toList());
    await _box.put('month_$month', raw);
  }
}
