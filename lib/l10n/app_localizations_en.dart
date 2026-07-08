// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Söderhamn Mosque';

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
  String get loading => 'Loading...';

  @override
  String get errorLoading => 'Could not load data';

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
  String get qiblaLocating => 'Getting location...';

  @override
  String get qiblaLocationDisabled => 'Location services disabled';

  @override
  String get qiblaLocationDisabledMessage =>
      'Enable location services to show the Qibla direction';

  @override
  String get qiblaPermissionDenied => 'Location permission denied';

  @override
  String get qiblaPermissionMessage =>
      'We need your location to calculate the direction to the Kaaba';

  @override
  String get qiblaOpenSettings => 'Open settings';

  @override
  String get qiblaUnavailable => 'Compass unavailable';

  @override
  String get qiblaUnavailableMessage =>
      'This device does not support compass functionality';

  @override
  String get qiblaBearing => 'Qibla direction';

  @override
  String get qiblaDistance => 'to Kaaba';

  @override
  String get qiblaTurn => 'Turn to align';

  @override
  String get qiblaAligned => 'Aligned';

  @override
  String get qiblaAccuracy => 'GPS accuracy';

  @override
  String get qiblaLowAccuracy => 'Low accuracy';

  @override
  String get qiblaCalibrate =>
      'Move your phone in a figure 8 to calibrate the compass';

  @override
  String get qiblaInterference =>
      'Magnetic interference detected move away from metal objects';

  @override
  String get qiblaRefresh => 'Refresh';
}
