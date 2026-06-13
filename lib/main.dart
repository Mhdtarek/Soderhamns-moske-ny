import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/datasources/local/ayah_local_ds.dart';
import 'data/datasources/local/prayer_times_local_ds.dart';
import 'features/ayah/providers/ayah_providers.dart';
import 'features/prayer_times/providers/prayer_times_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final prayerLocalDs = PrayerTimesLocalDs();
  await prayerLocalDs.init();
  await prayerLocalDs.loadFromAssets();

  final ayahLocalDs = AyahLocalDs();
  await ayahLocalDs.init();
  await ayahLocalDs.loadFallback();

  runApp(
    ProviderScope(
      overrides: [
        prayerTimesLocalDsProvider.overrideWithValue(prayerLocalDs),
        ayahLocalDsProvider.overrideWithValue(ayahLocalDs),
      ],
      child: const App(),
    ),
  );
}
