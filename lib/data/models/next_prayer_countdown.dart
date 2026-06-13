import 'package:freezed_annotation/freezed_annotation.dart';

part 'next_prayer_countdown.freezed.dart';

@freezed
class NextPrayerCountdown with _$NextPrayerCountdown {
  const factory NextPrayerCountdown({
    String? currentPrayerName,
    required String nextPrayerName,
    required String nextPrayerTime,
    required Duration remaining,
    required bool isTomorrow,
  }) = _NextPrayerCountdown;
}
