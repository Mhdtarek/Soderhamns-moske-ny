import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/features/prayer_times/providers/prayer_times_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<bool>>(prayerDataSyncProvider, (_, state) {
      state.whenData((updated) {
        if (updated && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bönetider uppdaterade'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Söderhamns Moské')),
      body: const Center(child: Text('Hem')),
    );
  }
}
