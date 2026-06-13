import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/core/theme/app_colors.dart';
import 'package:soderhamns_moske_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:soderhamns_moske_app/features/home/providers/home_providers.dart';
import 'package:soderhamns_moske_app/data/models/ayah.dart';
import 'package:soderhamns_moske_app/data/models/next_prayer_countdown.dart';
import 'package:soderhamns_moske_app/features/ayah/providers/ayah_providers.dart';
import 'package:soderhamns_moske_app/shared/widgets/prayer_times_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        ref.invalidate(nextPrayerCountdownProvider);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    final countdown = ref.watch(nextPrayerCountdownProvider);
    final dailyAyah = ref.watch(dailyAyahProvider);
    final todayTimes = ref.watch(todayPrayerTimesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Söderhamns Moské')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _CountdownContent(
                countdown: countdown,
                hijriDate: hijriDate,
                gregorianDate: gregorianDate,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: dailyAyah.when(
                loading: () => const SizedBox(
                  height: 60,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (e, _) => _buildAyahFallback(),
                data: (ayah) => _buildAyahContent(ayah),
              ),
            ),
          ),
          const SizedBox(height: 8),
          todayTimes.when(
            loading: () => const SizedBox(
              height: 60,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, _) => const SizedBox.shrink(),
            data: (day) => PrayerTimesCard(day: day, isToday: true),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahContent(Ayah ayah) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ayah.arabicText,
            style: theme.textTheme.titleLarge?.copyWith(
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              ayah.translation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${ayah.surahEnglishName} ${ayah.surahNumber}:${ayah.numberInSurah}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahFallback() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dagens vers',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text('Kunde inte ladda dagens vers'),
      ],
    );
  }
}

class _CountdownContent extends StatelessWidget {
  const _CountdownContent({
    required this.countdown,
    required this.hijriDate,
    required this.gregorianDate,
  });

  final AsyncValue<NextPrayerCountdown> countdown;
  final String hijriDate;
  final String gregorianDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final data = countdown.valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Date section — always visible
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gregorianDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hijriDate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (data?.currentPrayerName != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Be nu!',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const Divider(height: 16),
        // Countdown section — loading / error / data
        countdown.when(
          loading: () => const SizedBox(
            height: 32,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, __) => Text(
            'Kunde inte ladda bönetider',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          data: (data) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.currentPrayerName != null) ...[
                  Text(
                    'Aktuell bön',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.currentPrayerName!,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 16),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nästa: ${data.nextPrayerName}${data.isTomorrow ? ' (imorgon)' : ''}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      _formatDuration(data.remaining),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  static String _formatDuration(Duration d) {
    final positive = d.isNegative ? Duration.zero : d;
    final h = positive.inHours;
    final m = positive.inMinutes % 60;
    final s = positive.inSeconds % 60;
    return '${h}h ${m}m ${s}s';
  }
}
