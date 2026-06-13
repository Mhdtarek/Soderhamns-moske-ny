import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soderhamns_moske_app/data/models/ayah.dart';

class AyahLocalDs {
  static const _boxName = 'ayah_cache';
  static const _ayahKey = 'current_ayah';
  static const _dateKey = 'ayah_date';

  late Box<String> _box;
  late SharedPreferences _prefs;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadFallback() async {
    if (_box.containsKey(_ayahKey)) return;
    final jsonString =
        await rootBundle.loadString('assets/ayah/fallback.json');
    await _box.put(_ayahKey, jsonString);
    await _prefs.setString(_dateKey, 'fallback');
  }

  Ayah? getCachedAyah() {
    final jsonString = _box.get(_ayahKey);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Ayah.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  String? getCachedDate() {
    return _prefs.getString(_dateKey);
  }

  Future<void> cacheAyah(Ayah ayah) async {
    final jsonString = jsonEncode(ayah.toJson());
    await _box.put(_ayahKey, jsonString);
    await _prefs.setString(_dateKey, ayah.dateKey);
  }
}
