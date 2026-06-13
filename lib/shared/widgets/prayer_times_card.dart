import 'package:flutter/material.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';
import 'package:soderhamns_moske_app/shared/prayer_status.dart';
import 'package:soderhamns_moske_app/shared/widgets/prayer_row.dart';

class PrayerTimesCard extends StatelessWidget {
  final PrayerDay day;
  final bool isToday;

  const PrayerTimesCard({
    super.key,
    required this.day,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    String? currentPrayer;
    if (isToday) {
      final fajrParts = day.fajr.split(':');
      final shurukParts = day.shuruk.split(':');
      final dhohrParts = day.dhohr.split(':');
      final asrParts = day.asr.split(':');
      final maghribParts = day.maghrib.split(':');
      final ishaParts = day.isha.split(':');

      final fajrMin = int.parse(fajrParts[0]) * 60 + int.parse(fajrParts[1]);
      final shurukMin = int.parse(shurukParts[0]) * 60 + int.parse(shurukParts[1]);
      final dhohrMin = int.parse(dhohrParts[0]) * 60 + int.parse(dhohrParts[1]);
      final asrMin = int.parse(asrParts[0]) * 60 + int.parse(asrParts[1]);
      final maghribMin = int.parse(maghribParts[0]) * 60 + int.parse(maghribParts[1]);
      final ishaMin = int.parse(ishaParts[0]) * 60 + int.parse(ishaParts[1]);
      final nowMin = currentHour * 60 + currentMinute;

      if (nowMin >= fajrMin && nowMin < shurukMin) {
        currentPrayer = 'Fajr';
      } else if (nowMin >= dhohrMin && nowMin < asrMin) {
        currentPrayer = 'Dhohr';
      } else if (nowMin >= asrMin && nowMin < maghribMin) {
        currentPrayer = 'Asr';
      } else if (nowMin >= maghribMin && nowMin < ishaMin) {
        currentPrayer = 'Maghrib';
      } else if (nowMin >= ishaMin) {
        currentPrayer = 'Isha';
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PrayerRow(
              name: 'Fajr',
              time: day.fajr,
              status: _getStatus('Fajr', day.fajr, currentPrayer, isToday),
            ),
            const Divider(),
            PrayerRow(
              name: 'Shuruk',
              time: day.shuruk,
              status: PrayerStatus.none,
            ),
            const Divider(),
            PrayerRow(
              name: 'Dhohr',
              time: day.dhohr,
              status: _getStatus('Dhohr', day.dhohr, currentPrayer, isToday),
            ),
            const Divider(),
            PrayerRow(
              name: 'Asr',
              time: day.asr,
              status: _getStatus('Asr', day.asr, currentPrayer, isToday),
            ),
            const Divider(),
            PrayerRow(
              name: 'Maghrib',
              time: day.maghrib,
              status: _getStatus('Maghrib', day.maghrib, currentPrayer, isToday),
            ),
            const Divider(),
            PrayerRow(
              name: 'Isha',
              time: day.isha,
              status: _getStatus('Isha', day.isha, currentPrayer, isToday),
            ),
          ],
        ),
      ),
    );
  }

  PrayerStatus _getStatus(String name, String time, String? currentPrayer, bool isToday) {
    if (!isToday) return PrayerStatus.none;
    if (currentPrayer == null) return PrayerStatus.upcoming;
    if (name == currentPrayer) return PrayerStatus.current;

    final prayers = ['Fajr', 'Shuruk', 'Dhohr', 'Asr', 'Maghrib', 'Isha'];
    final currentIndex = prayers.indexOf(currentPrayer);
    final thisIndex = prayers.indexOf(name);

    if (thisIndex < currentIndex) return PrayerStatus.passed;
    return PrayerStatus.upcoming;
  }
}
