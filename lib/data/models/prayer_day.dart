import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer_day.freezed.dart';
part 'prayer_day.g.dart';

@freezed
class PrayerDay with _$PrayerDay {
  const factory PrayerDay({
    @JsonKey(name: 'Dat') required int date,
    @JsonKey(name: 'Fajr') required String fajr,
    @JsonKey(name: 'Shuruk') required String shuruk,
    @JsonKey(name: 'Dhohr') required String dhohr,
    @JsonKey(name: 'Asr') required String asr,
    @JsonKey(name: 'Maghrib') required String maghrib,
    @JsonKey(name: 'Isha') required String isha,
    String? hijriDate,
    String? gregorianLabel,
  }) = _PrayerDay;

  factory PrayerDay.fromJson(Map<String, dynamic> json) =>
      _$PrayerDayFromJson(json);
}
