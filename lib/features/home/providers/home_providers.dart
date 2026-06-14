import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:soderhamns_moske_app/data/models/next_prayer_countdown.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';
import 'package:soderhamns_moske_app/features/prayer_times/providers/prayer_times_providers.dart';

final hijriAdjustmentProvider = StateProvider<int>((ref) => 0);

final hijriDateProvider = Provider<String>((ref) {
  final adjustment = ref.watch(hijriAdjustmentProvider);
  final adjustedDate = DateTime.now().add(Duration(days: adjustment));
  final hijri = HijriCalendar.fromDate(adjustedDate);
  return '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear}';
});

final gregorianDateProvider = Provider<String>((ref) {
  try {
    return DateFormat('d MMMM y', 'sv').format(DateTime.now());
  } catch (_) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
});

final clockTickProvider = StreamProvider.autoDispose<int>((ref) {
  final controller = StreamController<int>();
  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    controller.add(0);
  });
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

final nextPrayerCountdownProvider =
    Provider<AsyncValue<NextPrayerCountdown>>((ref) {
  ref.watch(clockTickProvider);
  final today = ref.watch(todayPrayerTimesProvider).valueOrNull;
  final tomorrow = ref.watch(tomorrowPrayerTimesProvider).valueOrNull;
  if (today == null || tomorrow == null) return const AsyncValue.loading();
  return AsyncValue.data(_calculateNextPrayer(today, tomorrow));
});

const _prayerOrder = ['Fajr', 'Shuruk', 'Dhohr', 'Asr', 'Maghrib', 'Isha'];

int _parseMinutes(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

NextPrayerCountdown _calculateNextPrayer(PrayerDay today, PrayerDay tomorrow) {
  final now = DateTime.now();
  final nowMin = now.hour * 60 + now.minute;

  final times = {
    'Fajr': _parseMinutes(today.fajr),
    'Shuruk': _parseMinutes(today.shuruk),
    'Dhohr': _parseMinutes(today.dhohr),
    'Asr': _parseMinutes(today.asr),
    'Maghrib': _parseMinutes(today.maghrib),
    'Isha': _parseMinutes(today.isha),
  };

  final timeStrings = {
    'Fajr': today.fajr,
    'Shuruk': today.shuruk,
    'Dhohr': today.dhohr,
    'Asr': today.asr,
    'Maghrib': today.maghrib,
    'Isha': today.isha,
  };

  String? currentPrayerName;
  if (nowMin >= times['Fajr']! && nowMin < times['Shuruk']!) {
    currentPrayerName = 'Fajr';
  } else if (nowMin >= times['Dhohr']! && nowMin < times['Asr']!) {
    currentPrayerName = 'Dhohr';
  } else if (nowMin >= times['Asr']! && nowMin < times['Maghrib']!) {
    currentPrayerName = 'Asr';
  } else if (nowMin >= times['Maghrib']! && nowMin < times['Isha']!) {
    currentPrayerName = 'Maghrib';
  } else if (nowMin >= times['Isha']!) {
    currentPrayerName = 'Isha';
  }

  String nextPrayerName;
  int nextMinutes;
  bool isTomorrow = false;

  String? found;
  for (final name in _prayerOrder) {
    if (times[name]! > nowMin) {
      found = name;
      break;
    }
  }

  if (found != null) {
    nextPrayerName = found;
    nextMinutes = times[found]!;
  } else {
    nextPrayerName = 'Fajr';
    nextMinutes = _parseMinutes(tomorrow.fajr);
    isTomorrow = true;
  }

  late final DateTime nextDateTime;
  if (isTomorrow) {
    final tomorrowDate = now.add(const Duration(days: 1));
    nextDateTime = DateTime(tomorrowDate.year, tomorrowDate.month,
        tomorrowDate.day, nextMinutes ~/ 60, nextMinutes % 60);
  } else {
    nextDateTime = DateTime(
        now.year, now.month, now.day, nextMinutes ~/ 60, nextMinutes % 60);
  }

  final remaining = nextDateTime.difference(now);

  final String nextNextPrayerName;
  final String nextNextPrayerTime;

  if (isTomorrow) {
    nextNextPrayerName = 'Shuruk';
    nextNextPrayerTime = tomorrow.shuruk;
  } else {
    final nextIndex = _prayerOrder.indexOf(nextPrayerName);
    final nextNextIndex = nextIndex + 1;
    if (nextNextIndex < _prayerOrder.length) {
      nextNextPrayerName = _prayerOrder[nextNextIndex];
      nextNextPrayerTime = timeStrings[nextNextPrayerName]!;
    } else {
      nextNextPrayerName = 'Fajr';
      nextNextPrayerTime = tomorrow.fajr;
    }
  }

  return NextPrayerCountdown(
    currentPrayerName: currentPrayerName,
    nextPrayerName: nextPrayerName,
    nextPrayerTime: isTomorrow ? tomorrow.fajr : timeStrings[nextPrayerName]!,
    remaining: remaining,
    isTomorrow: isTomorrow,
    nextNextPrayerName: nextNextPrayerName,
    nextNextPrayerTime: nextNextPrayerTime,
  );
}
