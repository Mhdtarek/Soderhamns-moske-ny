// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrayerDayImpl _$$PrayerDayImplFromJson(Map<String, dynamic> json) =>
    _$PrayerDayImpl(
      date: (json['Dat'] as num).toInt(),
      fajr: json['Fajr'] as String,
      shuruk: json['Shuruk'] as String,
      dhohr: json['Dhohr'] as String,
      asr: json['Asr'] as String,
      maghrib: json['Maghrib'] as String,
      isha: json['Isha'] as String,
      hijriDate: json['hijriDate'] as String?,
      gregorianLabel: json['gregorianLabel'] as String?,
    );

Map<String, dynamic> _$$PrayerDayImplToJson(_$PrayerDayImpl instance) =>
    <String, dynamic>{
      'Dat': instance.date,
      'Fajr': instance.fajr,
      'Shuruk': instance.shuruk,
      'Dhohr': instance.dhohr,
      'Asr': instance.asr,
      'Maghrib': instance.maghrib,
      'Isha': instance.isha,
      'hijriDate': instance.hijriDate,
      'gregorianLabel': instance.gregorianLabel,
    };
