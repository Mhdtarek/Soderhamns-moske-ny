import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:soderhamns_moske_app/features/home/providers/home_providers.dart';

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

    final hijriDate = ref.watch(hijriDateProvider);
    final gregorianDate = ref.watch(gregorianDateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Söderhamns Moské')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    gregorianDate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hijriDate,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
