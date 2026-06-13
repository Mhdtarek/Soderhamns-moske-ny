import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

final dayByTabProvider = FutureProvider.family<PrayerDay, int>((ref, index) async {
  final repo = ref.watch(prayerTimesRepositoryProvider);
  switch (index) {
    case 0:
      return repo.getYesterday();
    case 1:
      return repo.getToday();
    default:
      return repo.getTomorrow();
  }
});

int getIsoWeekNumber(DateTime date) {
  final dayOfYear = int.parse(
      DateFormat('D').format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = getIsoWeekNumber(DateTime(date.year - 1, 12, 31));
  } else if (woy > 52) {
    final dec31 = DateTime(date.year, 12, 31);
    if (dec31.weekday < 4) woy = 1;
  }
  return woy;
}

int getIsoWeekYear(DateTime date) {
  final dayOfYear = int.parse(DateFormat('D').format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) return date.year - 1;
  if (woy > 52) {
    final dec31 = DateTime(date.year, 12, 31);
    if (dec31.weekday < 4) return date.year + 1;
  }
  return date.year;
}

DateTime getMondayOfWeek(int weekYear, int weekNumber) {
  final jan4 = DateTime(weekYear, 1, 4);
  final mondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
  return mondayOfWeek1.add(Duration(days: (weekNumber - 1) * 7));
}

int getWeeksInYear(int year) {
  final dec28 = DateTime(year, 12, 28);
  return getIsoWeekNumber(dec28);
}

final weekPrayerTimesProvider =
    FutureProvider.family<List<PrayerDay>, int>((ref, weekNumber) async {
  final now = DateTime.now();
  final weekYear = getIsoWeekYear(now);
  final monday = getMondayOfWeek(weekYear, weekNumber);
  final repo = ref.watch(prayerTimesRepositoryProvider);

  final days = <PrayerDay>[];
  for (int i = 0; i < 7; i++) {
    final day = monday.add(Duration(days: i));
    final monthData = repo.getMonth(day.month);
    final dayData = monthData.where((d) => d.date == day.day).toList();
    if (dayData.isNotEmpty) {
      days.add(dayData.first);
    }
  }
  return days;
});

final prayerDataSyncProvider = FutureProvider<bool>((ref) async {
  return ref.watch(prayerTimesRepositoryProvider).syncIfNeeded();
});

