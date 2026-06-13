import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayah.freezed.dart';
part 'ayah.g.dart';

@freezed
class Ayah with _$Ayah {
  const factory Ayah({
    @JsonKey(name: 'number') required int number,
    @JsonKey(name: 'surahNumber') required int surahNumber,
    @JsonKey(name: 'surahName') required String surahName,
    @JsonKey(name: 'surahEnglishName') required String surahEnglishName,
    @JsonKey(name: 'numberInSurah') required int numberInSurah,
    @JsonKey(name: 'arabicText') required String arabicText,
    @JsonKey(name: 'translation') required String translation,
    @JsonKey(name: 'dateKey') required String dateKey,
  }) = _Ayah;

  factory Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);
}
