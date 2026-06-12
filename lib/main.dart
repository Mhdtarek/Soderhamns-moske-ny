import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/datasources/local/prayer_times_local_ds.dart';
import 'features/prayer_times/providers/prayer_times_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final localDs = PrayerTimesLocalDs();
  await localDs.init();
  await localDs.loadFromAssets();

  runApp(
    ProviderScope(
      overrides: [
        prayerTimesLocalDsProvider.overrideWithValue(localDs),
      ],
      child: const App(),
    ),
  );
}
