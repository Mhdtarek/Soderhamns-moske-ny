import 'package:soderhamns_moske_app/data/datasources/local/prayer_times_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/prayer_times_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';

class PrayerTimesRepository {
  final PrayerTimesLocalDs local;
  final PrayerTimesRemoteDs remote;

  PrayerTimesRepository({required this.local, required this.remote});

  List<PrayerDay> getMonth(int month) {
    return local.getMonth(month);
  }

  PrayerDay getToday() {
    final now = DateTime.now();
    final days = local.getMonth(now.month);
    final today = days.where((d) => d.date == now.day);
    if (today.isEmpty) throw const CacheException();
    return today.first;
  }

  PrayerDay getYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final days = local.getMonth(yesterday.month);
    final match = days.where((d) => d.date == yesterday.day);
    if (match.isEmpty) throw const CacheException();
    return match.first;
  }

  PrayerDay getTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final days = local.getMonth(tomorrow.month);
    final match = days.where((d) => d.date == tomorrow.day);
    if (match.isEmpty) throw const CacheException();
    return match.first;
  }

  Future<void> syncFromRemote() async {
    for (var month = 1; month <= 12; month++) {
      final data = await remote.getMonth(month);
      await local.cacheMonth(month, data);
    }
  }

  Future<bool> syncIfNeeded() async {
    final remoteYear = await remote.getYear();
    final cachedYear = local.getCachedYear();

    if (cachedYear == remoteYear) return false;

    await syncFromRemote();
    await local.setCachedYear(remoteYear);
    return true;
  }
}
