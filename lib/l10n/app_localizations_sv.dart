// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Söderhamns Moské';

  @override
  String get home => 'Hem';

  @override
  String get prayerTimes => 'Bönetider';

  @override
  String get news => 'Nyheter';

  @override
  String get more => 'Mer';

  @override
  String get donate => 'Donera';

  @override
  String get contact => 'Kontakt';

  @override
  String get settings => 'Inställningar';

  @override
  String get qibla => 'Qibla';

  @override
  String get yesterday => 'Igår';

  @override
  String get today => 'Idag';

  @override
  String get tomorrow => 'Imorgon';

  @override
  String get retry => 'Försök igen';

  @override
  String get loading => 'Laddar...';

  @override
  String get errorLoading => 'Kunde inte ladda data';

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
  String get qiblaLocating => 'Hämtar position...';

  @override
  String get qiblaLocationDisabled => 'Platstjänster avstängda';

  @override
  String get qiblaLocationDisabledMessage =>
      'Aktivera platstjänster för att visa Qibla-riktningen';

  @override
  String get qiblaPermissionDenied => 'Platstjänst nekad';

  @override
  String get qiblaPermissionMessage =>
      'Vi behöver din position för att beräkna riktningen till Kaaba';

  @override
  String get qiblaOpenSettings => 'Öppna inställningar';

  @override
  String get qiblaUnavailable => 'Kompass ej tillgänglig';

  @override
  String get qiblaUnavailableMessage => 'Denna enhet saknar kompassfunktion';

  @override
  String get qiblaBearing => 'Qibla-riktning';

  @override
  String get qiblaDistance => 'till Kaaba';

  @override
  String get qiblaTurn => 'Vrid för att rikta';

  @override
  String get qiblaAligned => 'Riktad';

  @override
  String get qiblaAccuracy => 'GPS-noggrannhet';

  @override
  String get qiblaLowAccuracy => 'Låg noggrannhet';

  @override
  String get qiblaCalibrate =>
      'Rotera telefonen i en åtta för att kalibrera kompassen';

  @override
  String get qiblaInterference =>
      'Magnetisk störning upptäckt avlägsna dig från metallföremål';

  @override
  String get qiblaRefresh => 'Uppdatera';
}
