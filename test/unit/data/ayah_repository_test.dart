import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/data/datasources/local/ayah_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/ayah_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/ayah.dart';
import 'package:soderhamns_moske_app/data/repositories/ayah_repository.dart';

class MockAyahLocalDs extends Mock implements AyahLocalDs {}

class MockAyahRemoteDs extends Mock implements AyahRemoteDs {}

const testAyah = Ayah(
  number: 1,
  surahNumber: 1,
  surahName: 'الفاتحة',
  surahEnglishName: 'Al-Faatiha',
  numberInSurah: 1,
  arabicText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
  translation: 'I GUDS, DEN NÅDERIKES, DEN BARMHÄRTIGES NAMN',
  dateKey: '2026-01-01',
);

void main() {
  late MockAyahLocalDs mockLocal;
  late MockAyahRemoteDs mockRemote;
  late AyahRepository repository;

  setUpAll(() {
    registerFallbackValue(testAyah);
  });

  setUp(() {
    mockLocal = MockAyahLocalDs();
    mockRemote = MockAyahRemoteDs();
    repository = AyahRepository(local: mockLocal, remote: mockRemote);
  });

  group('getDailyAyah', () {
    test('returns cached ayah when available', () {
      when(() => mockLocal.getCachedAyah()).thenReturn(testAyah);

      final result = repository.getDailyAyah();

      expect(result, testAyah);
      verify(() => mockLocal.getCachedAyah()).called(1);
      verifyNever(() => mockRemote.getAyah(any()));
    });

    test('returns null when no cache exists', () {
      when(() => mockLocal.getCachedAyah()).thenReturn(null);

      final result = repository.getDailyAyah();

      expect(result, isNull);
    });
  });

  group('syncIfNeeded', () {
    test('returns cached ayah when cached date matches today', () async {
      final today = AyahRemoteDs.todayKey();
      when(() => mockLocal.getCachedDate()).thenReturn(today);
      when(() => mockLocal.getCachedAyah()).thenReturn(testAyah);

      final result = await repository.syncIfNeeded();

      expect(result, testAyah);
      verifyNever(() => mockRemote.getAyah(any()));
    });

    test('fetches from remote when no cache exists for today', () async {
      when(() => mockLocal.getCachedDate()).thenReturn('2020-01-01');
      when(() => mockRemote.getAyah(any())).thenAnswer((_) async => testAyah);
      when(() => mockLocal.cacheAyah(any())).thenAnswer((_) async {});

      final result = await repository.syncIfNeeded();

      expect(result, testAyah);
      verify(() => mockRemote.getAyah(any())).called(1);
      verify(() => mockLocal.cacheAyah(testAyah)).called(1);
    });

    test('returns cached ayah when remote fails', () async {
      when(() => mockLocal.getCachedDate()).thenReturn('2020-01-01');
      when(() => mockRemote.getAyah(any()))
          .thenAnswer((_) async => throw const NetworkException());
      when(() => mockLocal.getCachedAyah()).thenReturn(testAyah);

      final result = await repository.syncIfNeeded();

      expect(result, testAyah);
      verify(() => mockRemote.getAyah(any())).called(1);
      verifyNever(() => mockLocal.cacheAyah(any()));
    });

    test('returns cached ayah when remote throws ParseException', () async {
      when(() => mockLocal.getCachedDate()).thenReturn('2020-01-01');
      when(() => mockRemote.getAyah(any()))
          .thenAnswer((_) async => throw const ParseException());
      when(() => mockLocal.getCachedAyah()).thenReturn(testAyah);

      final result = await repository.syncIfNeeded();

      expect(result, testAyah);
    });

    test('rethrows when remote fails and no cache exists', () async {
      when(() => mockLocal.getCachedDate()).thenReturn('2020-01-01');
      when(() => mockRemote.getAyah(any()))
          .thenAnswer((_) async => throw const NetworkException());
      when(() => mockLocal.getCachedAyah()).thenReturn(null);

      expect(
        () => repository.syncIfNeeded(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('returns cached even when cache date is null and remote fails', () async {
      when(() => mockLocal.getCachedDate()).thenReturn(null);
      when(() => mockRemote.getAyah(any()))
          .thenAnswer((_) async => throw const NetworkException());
      when(() => mockLocal.getCachedAyah()).thenReturn(testAyah);

      final result = await repository.syncIfNeeded();

      expect(result, testAyah);
    });
  });
}
