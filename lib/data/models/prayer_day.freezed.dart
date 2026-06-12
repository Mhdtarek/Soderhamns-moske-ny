// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PrayerDay _$PrayerDayFromJson(Map<String, dynamic> json) {
  return _PrayerDay.fromJson(json);
}

/// @nodoc
mixin _$PrayerDay {
  @JsonKey(name: 'Dat')
  int get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'Fajr')
  String get fajr => throw _privateConstructorUsedError;
  @JsonKey(name: 'Shuruk')
  String get shuruk => throw _privateConstructorUsedError;
  @JsonKey(name: 'Dhohr')
  String get dhohr => throw _privateConstructorUsedError;
  @JsonKey(name: 'Asr')
  String get asr => throw _privateConstructorUsedError;
  @JsonKey(name: 'Maghrib')
  String get maghrib => throw _privateConstructorUsedError;
  @JsonKey(name: 'Isha')
  String get isha => throw _privateConstructorUsedError;
  String? get hijriDate => throw _privateConstructorUsedError;
  String? get gregorianLabel => throw _privateConstructorUsedError;

  /// Serializes this PrayerDay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrayerDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrayerDayCopyWith<PrayerDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrayerDayCopyWith<$Res> {
  factory $PrayerDayCopyWith(PrayerDay value, $Res Function(PrayerDay) then) =
      _$PrayerDayCopyWithImpl<$Res, PrayerDay>;
  @useResult
  $Res call({
    @JsonKey(name: 'Dat') int date,
    @JsonKey(name: 'Fajr') String fajr,
    @JsonKey(name: 'Shuruk') String shuruk,
    @JsonKey(name: 'Dhohr') String dhohr,
    @JsonKey(name: 'Asr') String asr,
    @JsonKey(name: 'Maghrib') String maghrib,
    @JsonKey(name: 'Isha') String isha,
    String? hijriDate,
    String? gregorianLabel,
  });
}

/// @nodoc
class _$PrayerDayCopyWithImpl<$Res, $Val extends PrayerDay>
    implements $PrayerDayCopyWith<$Res> {
  _$PrayerDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrayerDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? fajr = null,
    Object? shuruk = null,
    Object? dhohr = null,
    Object? asr = null,
    Object? maghrib = null,
    Object? isha = null,
    Object? hijriDate = freezed,
    Object? gregorianLabel = freezed,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as int,
            fajr: null == fajr
                ? _value.fajr
                : fajr // ignore: cast_nullable_to_non_nullable
                      as String,
            shuruk: null == shuruk
                ? _value.shuruk
                : shuruk // ignore: cast_nullable_to_non_nullable
                      as String,
            dhohr: null == dhohr
                ? _value.dhohr
                : dhohr // ignore: cast_nullable_to_non_nullable
                      as String,
            asr: null == asr
                ? _value.asr
                : asr // ignore: cast_nullable_to_non_nullable
                      as String,
            maghrib: null == maghrib
                ? _value.maghrib
                : maghrib // ignore: cast_nullable_to_non_nullable
                      as String,
            isha: null == isha
                ? _value.isha
                : isha // ignore: cast_nullable_to_non_nullable
                      as String,
            hijriDate: freezed == hijriDate
                ? _value.hijriDate
                : hijriDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            gregorianLabel: freezed == gregorianLabel
                ? _value.gregorianLabel
                : gregorianLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrayerDayImplCopyWith<$Res>
    implements $PrayerDayCopyWith<$Res> {
  factory _$$PrayerDayImplCopyWith(
    _$PrayerDayImpl value,
    $Res Function(_$PrayerDayImpl) then,
  ) = __$$PrayerDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Dat') int date,
    @JsonKey(name: 'Fajr') String fajr,
    @JsonKey(name: 'Shuruk') String shuruk,
    @JsonKey(name: 'Dhohr') String dhohr,
    @JsonKey(name: 'Asr') String asr,
    @JsonKey(name: 'Maghrib') String maghrib,
    @JsonKey(name: 'Isha') String isha,
    String? hijriDate,
    String? gregorianLabel,
  });
}

/// @nodoc
class __$$PrayerDayImplCopyWithImpl<$Res>
    extends _$PrayerDayCopyWithImpl<$Res, _$PrayerDayImpl>
    implements _$$PrayerDayImplCopyWith<$Res> {
  __$$PrayerDayImplCopyWithImpl(
    _$PrayerDayImpl _value,
    $Res Function(_$PrayerDayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PrayerDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? fajr = null,
    Object? shuruk = null,
    Object? dhohr = null,
    Object? asr = null,
    Object? maghrib = null,
    Object? isha = null,
    Object? hijriDate = freezed,
    Object? gregorianLabel = freezed,
  }) {
    return _then(
      _$PrayerDayImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as int,
        fajr: null == fajr
            ? _value.fajr
            : fajr // ignore: cast_nullable_to_non_nullable
                  as String,
        shuruk: null == shuruk
            ? _value.shuruk
            : shuruk // ignore: cast_nullable_to_non_nullable
                  as String,
        dhohr: null == dhohr
            ? _value.dhohr
            : dhohr // ignore: cast_nullable_to_non_nullable
                  as String,
        asr: null == asr
            ? _value.asr
            : asr // ignore: cast_nullable_to_non_nullable
                  as String,
        maghrib: null == maghrib
            ? _value.maghrib
            : maghrib // ignore: cast_nullable_to_non_nullable
                  as String,
        isha: null == isha
            ? _value.isha
            : isha // ignore: cast_nullable_to_non_nullable
                  as String,
        hijriDate: freezed == hijriDate
            ? _value.hijriDate
            : hijriDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        gregorianLabel: freezed == gregorianLabel
            ? _value.gregorianLabel
            : gregorianLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrayerDayImpl implements _PrayerDay {
  const _$PrayerDayImpl({
    @JsonKey(name: 'Dat') required this.date,
    @JsonKey(name: 'Fajr') required this.fajr,
    @JsonKey(name: 'Shuruk') required this.shuruk,
    @JsonKey(name: 'Dhohr') required this.dhohr,
    @JsonKey(name: 'Asr') required this.asr,
    @JsonKey(name: 'Maghrib') required this.maghrib,
    @JsonKey(name: 'Isha') required this.isha,
    this.hijriDate,
    this.gregorianLabel,
  });

  factory _$PrayerDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrayerDayImplFromJson(json);

  @override
  @JsonKey(name: 'Dat')
  final int date;
  @override
  @JsonKey(name: 'Fajr')
  final String fajr;
  @override
  @JsonKey(name: 'Shuruk')
  final String shuruk;
  @override
  @JsonKey(name: 'Dhohr')
  final String dhohr;
  @override
  @JsonKey(name: 'Asr')
  final String asr;
  @override
  @JsonKey(name: 'Maghrib')
  final String maghrib;
  @override
  @JsonKey(name: 'Isha')
  final String isha;
  @override
  final String? hijriDate;
  @override
  final String? gregorianLabel;

  @override
  String toString() {
    return 'PrayerDay(date: $date, fajr: $fajr, shuruk: $shuruk, dhohr: $dhohr, asr: $asr, maghrib: $maghrib, isha: $isha, hijriDate: $hijriDate, gregorianLabel: $gregorianLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrayerDayImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.fajr, fajr) || other.fajr == fajr) &&
            (identical(other.shuruk, shuruk) || other.shuruk == shuruk) &&
            (identical(other.dhohr, dhohr) || other.dhohr == dhohr) &&
            (identical(other.asr, asr) || other.asr == asr) &&
            (identical(other.maghrib, maghrib) || other.maghrib == maghrib) &&
            (identical(other.isha, isha) || other.isha == isha) &&
            (identical(other.hijriDate, hijriDate) ||
                other.hijriDate == hijriDate) &&
            (identical(other.gregorianLabel, gregorianLabel) ||
                other.gregorianLabel == gregorianLabel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    fajr,
    shuruk,
    dhohr,
    asr,
    maghrib,
    isha,
    hijriDate,
    gregorianLabel,
  );

  /// Create a copy of PrayerDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrayerDayImplCopyWith<_$PrayerDayImpl> get copyWith =>
      __$$PrayerDayImplCopyWithImpl<_$PrayerDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrayerDayImplToJson(this);
  }
}

abstract class _PrayerDay implements PrayerDay {
  const factory _PrayerDay({
    @JsonKey(name: 'Dat') required final int date,
    @JsonKey(name: 'Fajr') required final String fajr,
    @JsonKey(name: 'Shuruk') required final String shuruk,
    @JsonKey(name: 'Dhohr') required final String dhohr,
    @JsonKey(name: 'Asr') required final String asr,
    @JsonKey(name: 'Maghrib') required final String maghrib,
    @JsonKey(name: 'Isha') required final String isha,
    final String? hijriDate,
    final String? gregorianLabel,
  }) = _$PrayerDayImpl;

  factory _PrayerDay.fromJson(Map<String, dynamic> json) =
      _$PrayerDayImpl.fromJson;

  @override
  @JsonKey(name: 'Dat')
  int get date;
  @override
  @JsonKey(name: 'Fajr')
  String get fajr;
  @override
  @JsonKey(name: 'Shuruk')
  String get shuruk;
  @override
  @JsonKey(name: 'Dhohr')
  String get dhohr;
  @override
  @JsonKey(name: 'Asr')
  String get asr;
  @override
  @JsonKey(name: 'Maghrib')
  String get maghrib;
  @override
  @JsonKey(name: 'Isha')
  String get isha;
  @override
  String? get hijriDate;
  @override
  String? get gregorianLabel;

  /// Create a copy of PrayerDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrayerDayImplCopyWith<_$PrayerDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
