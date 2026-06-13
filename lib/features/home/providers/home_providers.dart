import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

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
