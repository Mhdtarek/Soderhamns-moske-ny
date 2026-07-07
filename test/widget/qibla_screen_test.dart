import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soderhamns_moske_app/features/qibla/presentation/qibla_screen.dart';
import 'package:soderhamns_moske_app/features/qibla/presentation/widgets/compass_widget.dart';
import 'package:soderhamns_moske_app/features/qibla/providers/qibla_providers.dart';
import 'package:soderhamns_moske_app/l10n/app_localizations.dart';

// fake position for tests
final _testPosition = Position(
  latitude: 59.33,
  longitude: 18.07,
  timestamp: DateTime.now(),
  accuracy: 8,
  altitude: 0,
  heading: 0,
  speed: 0,
  speedAccuracy: 0,
  altitudeAccuracy: 0,
  headingAccuracy: 0,
);

// localization stub so tests dont need full l10n
class _TestLocalizations extends AppLocalizations {
  _TestLocalizations() : super('en');

  @override
  String get appTitle => 'Test';
  @override
  String get home => 'Home';
  @override
  String get prayerTimes => 'Prayer Times';
  @override
  String get news => 'News';
  @override
  String get more => 'More';
  @override
  String get donate => 'Donate';
  @override
  String get contact => 'Contact';
  @override
  String get settings => 'Settings';
  @override
  String get qibla => 'Qibla';
  @override
  String get yesterday => 'Yesterday';
  @override
  String get today => 'Today';
  @override
  String get tomorrow => 'Tomorrow';
  @override
  String get retry => 'Retry';
  @override
  String get loading => 'Loading';
  @override
  String get errorLoading => 'Error';
  @override
  String get fajr => 'Fajr';
  @override
  String get shuruk => 'Shuruk';
  @override
  String get dhohr => 'Dhohr';
  @override
  String get asr => 'Asr';
  @override
  String get maghrib => 'Maghrib';
  @override
  String get isha => 'Isha';
  @override
  String get qiblaLocating => 'Getting location';
  @override
  String get qiblaLocationDisabled => 'Location disabled';
  @override
  String get qiblaLocationDisabledMessage => 'Enable location';
  @override
  String get qiblaPermissionDenied => 'Permission denied';
  @override
  String get qiblaPermissionMessage => 'Need location';
  @override
  String get qiblaOpenSettings => 'Open settings';
  @override
  String get qiblaUnavailable => 'Compass unavailable';
  @override
  String get qiblaUnavailableMessage => 'No compass';
  @override
  String get qiblaBearing => 'Qibla direction';
  @override
  String get qiblaDistance => 'to Kaaba';
  @override
  String get qiblaAccuracy => 'GPS accuracy';
  @override
  String get qiblaLowAccuracy => 'Low accuracy';
  @override
  String get qiblaCalibrate => 'Calibrate';
  @override
  String get qiblaRefresh => 'Refresh';
}

// helper widget that wraps qibla screen with localization
Widget _wrapApp(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: const [
        _TestLocalizationsDelegate(),
      ],
      supportedLocales: const [Locale('en')],
      home: const QiblaScreen(),
    ),
  );
}

class _TestLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _TestLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      _TestLocalizations();

  @override
  bool shouldReload(old) => false;
}

void main() {
  testWidgets('permission denied shows message and settings button',
      (tester) async {
    await tester.pumpWidget(_wrapApp([
      permissionProvider.overrideWith((ref) async => QiblaPermissionStatus.denied),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Permission denied'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('location disabled shows enable prompt', (tester) async {
    await tester.pumpWidget(_wrapApp([
      permissionProvider.overrideWith(
              (ref) async => QiblaPermissionStatus.locationDisabled),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Location disabled'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('granted with heading null shows compass unavailable',
      (tester) async {
    // stream that never emits so heading stays null
    final neverController = StreamController<double>();
    addTearDown(neverController.close);

    await tester.pumpWidget(_wrapApp([
      permissionProvider.overrideWith((ref) async => QiblaPermissionStatus.granted),
      locationProvider.overrideWith((ref) async => _testPosition),
      compassHeadingProvider.overrideWith((ref) => neverController.stream),
    ]));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('No compass'), findsOneWidget);
  });

  testWidgets('granted with heading shows compass', (tester) async {
    await tester.pumpWidget(_wrapApp([
      permissionProvider.overrideWith((ref) async => QiblaPermissionStatus.granted),
      locationProvider.overrideWith((ref) async => _testPosition),
      compassHeadingProvider.overrideWith((ref) => Stream.value(90.0)),
    ]));
    await tester.pumpAndSettle();

    // compass widget should be visible
    expect(find.byType(CompassWidget), findsOneWidget);
    // bearing text should show
    expect(find.text('Qibla direction'), findsOneWidget);
  });

  testWidgets('low accuracy shows warning banner', (tester) async {
    final lowAccPosition = Position(
      latitude: 59.33,
      longitude: 18.07,
      timestamp: DateTime.now(),
      accuracy: 50,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    await tester.pumpWidget(_wrapApp([
      permissionProvider.overrideWith((ref) async => QiblaPermissionStatus.granted),
      locationProvider.overrideWith((ref) async => lowAccPosition),
      compassHeadingProvider.overrideWith((ref) => Stream.value(90.0)),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Low accuracy'), findsOneWidget);
  });
}