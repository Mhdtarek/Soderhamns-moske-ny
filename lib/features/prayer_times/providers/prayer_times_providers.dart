import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/data/datasources/local/prayer_times_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/prayer_times_remote_ds.dart';
import 'package:soderhamns_moske_app/data/repositories/prayer_times_repository.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';

final prayerTimesLocalDsProvider = Provider<PrayerTimesLocalDs>((ref) {
  return PrayerTimesLocalDs();
});

final prayerTimesRemoteDsProvider = Provider<PrayerTimesRemoteDs>((ref) {
  return PrayerTimesRemoteDs();
});

final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>((ref) {
  return PrayerTimesRepository(
    local: ref.watch(prayerTimesLocalDsProvider),
    remote: ref.watch(prayerTimesRemoteDsProvider),
  );
});

final monthPrayerTimesProvider = FutureProvider.family<List<PrayerDay>, int>(
  (ref, month) async {
    return ref.watch(prayerTimesRepositoryProvider).getMonth(month);
  },
);

final todayPrayerTimesProvider = FutureProvider<PrayerDay>((ref) async {
  return ref.watch(prayerTimesRepositoryProvider).getToday();
});

final yesterdayPrayerTimesProvider = FutureProvider<PrayerDay>((ref) async {
  return ref.watch(prayerTimesRepositoryProvider).getYesterday();
});

final tomorrowPrayerTimesProvider = FutureProvider<PrayerDay>((ref) async {
  return ref.watch(prayerTimesRepositoryProvider).getTomorrow();
});
