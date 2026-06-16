import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/core/theme/app_colors.dart';
import 'package:soderhamns_moske_app/data/models/ayah.dart';
import 'package:soderhamns_moske_app/data/models/next_prayer_countdown.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';
import 'package:soderhamns_moske_app/features/ayah/providers/ayah_providers.dart';
import 'package:soderhamns_moske_app/features/home/providers/home_providers.dart';
import 'package:soderhamns_moske_app/features/home/presentation/widgets/latest_news_card.dart';
import 'package:soderhamns_moske_app/features/news/providers/news_providers.dart';
import 'package:soderhamns_moske_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:soderhamns_moske_app/shared/widgets/error_view.dart';
import 'package:soderhamns_moske_app/shared/widgets/loading_view.dart';

const _grey888 = Color(0xFF888888);
const _grey555 = Color(0xFF555555);
const _grey333 = Color(0xFF333333);
const _grey666 = Color(0xFF666666);
const _dark = Color(0xFF2C2A22);
const _green = Color(0xFF4A7C59);
const _dividerLight = Color(0x1A000000);
const _dividerMedium = Color(0x12000000);
const _tint = Color(0x05000000);
const _activeBg = Color(0xFFF5F0E4);

const _prayerOrder = ['Fajr', 'Shuruk', 'Dhohr', 'Asr', 'Maghrib', 'Isha'];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _heroFade, _heroSlide;
  late Animation<double> _ayahFade, _ayahSlide;
  late Animation<double> _listFade, _listSlide;
  late Animation<double> _newsFade, _newsSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heroFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _heroSlide = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _ayahFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _ayahSlide = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _listFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );
    _listSlide = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );
    _newsFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _newsSlide = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
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
    final newsAsync = ref.watch(newsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Söderhamns Moské')),
      body: ListView(
        physics: Theme.of(context).platform == TargetPlatform.iOS
            ? const BouncingScrollPhysics()
            : null,
        padding: const EdgeInsets.only(top: 0, bottom: 16),
        children: [
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _heroFade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(_heroSlide),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _PrayerHeroCard(
                  gregorianDate: gregorianDate,
                  hijriDate: hijriDate,
                  countdown: countdown,
                  onRetry: () => ref.invalidate(nextPrayerCountdownProvider),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _ayahFade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(_ayahSlide),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _AyahCard(dailyAyah: dailyAyah),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _listFade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(_listSlide),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _PrayerListCard(
                  todayTimes: todayTimes,
                  currentPrayerName: countdown.valueOrNull?.currentPrayerName,
                  onRetry: () => ref.invalidate(todayPrayerTimesProvider),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _newsFade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(_newsSlide),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: LatestNewsCard(newsAsync: newsAsync),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card 1: Prayer Hero ────────────────────────────────────────

class _PrayerHeroCard extends StatelessWidget {
  const _PrayerHeroCard({
    required this.gregorianDate,
    required this.hijriDate,
    required this.countdown,
    this.onRetry,
  });

  final String gregorianDate;
  final String hijriDate;
  final AsyncValue<NextPrayerCountdown> countdown;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final data = countdown.valueOrNull;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zone 1 — Date row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gregorianDate,
                      style: const TextStyle(fontSize: 12, color: _grey888),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hijriDate,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _grey555,
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
          ),
          const Divider(height: 1, thickness: 0.5, color: _dividerLight),
          // Zone 2 — Current prayer + countdown
          Padding(
            padding: const EdgeInsets.all(12),
            child: countdown.when(
              loading: () => const SizedBox(
                height: 56,
                child: Center(child: LoadingView()),
              ),
              error: (_, __) => ErrorView(
                message: 'Kunde inte ladda bönetider',
                onRetry: onRetry,
              ),
              data: (data) {
                final hasCurrent = data.currentPrayerName != null;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasCurrent ? 'Aktuell bön' : 'Nästa bön',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _grey888,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasCurrent
                                ? data.currentPrayerName!
                                : data.nextPrayerName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              color: _dark,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasCurrent)
                          Text(
                            'Nästa: ${data.nextPrayerName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _grey888,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCountdown(data.remaining),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: _green,
                            fontFeatures: [FontFeature.tabularFigures()],
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: _dividerLight),
          // Zone 3 — Next prayers hint
          countdown.when(
            loading: () => const SizedBox(height: 36),
            error: (_, __) => const SizedBox.shrink(),
            data: (data) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: _tint),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: _grey888),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: data.nextPrayerName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _grey333,
                            ),
                          ),
                          TextSpan(
                            text: ' kl. ${data.nextPrayerTime}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _grey666,
                            ),
                          ),
                          const TextSpan(
                            text: ', sedan ',
                            style: TextStyle(fontSize: 13, color: _grey666),
                          ),
                          TextSpan(
                            text: data.nextNextPrayerName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _grey333,
                            ),
                          ),
                          TextSpan(
                            text: ' kl. ${data.nextNextPrayerTime}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _grey666,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatCountdown(Duration d) {
    final positive = d.isNegative ? Duration.zero : d;
    final h = positive.inHours.toString().padLeft(2, '0');
    final m = (positive.inMinutes % 60).toString().padLeft(2, '0');
    final s = (positive.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

// ─── Card 2: Ayah ───────────────────────────────────────────────

class _AyahCard extends StatelessWidget {
  const _AyahCard({required this.dailyAyah});

  final AsyncValue<Ayah> dailyAyah;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: dailyAyah.when(
        loading: () => const SizedBox(height: 60, child: LoadingView()),
        error: (_, __) => const SizedBox(height: 60, child: LoadingView()),
        data: (ayah) {
          final theme = Theme.of(context);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ayah.arabicText,
                    style: theme.textTheme.titleLarge?.copyWith(
                      height: 1.8,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      ayah.translation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _grey666,
                        height: 1.6,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${ayah.surahEnglishName} ${ayah.surahNumber}:${ayah.numberInSurah}',
                        style: const TextStyle(fontSize: 11, color: _grey888),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Card 3: Prayer List ────────────────────────────────────────

class _PrayerListCard extends StatelessWidget {
  const _PrayerListCard({
    required this.todayTimes,
    required this.currentPrayerName,
    this.onRetry,
  });

  final AsyncValue<PrayerDay> todayTimes;
  final String? currentPrayerName;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;

    return todayTimes.when(
      loading: () =>
          Card(child: const SizedBox(height: 60, child: LoadingView())),
      error: (_, __) => Card(
        child: ErrorView(
          message: 'Kunde inte ladda bönetider',
          onRetry: onRetry,
        ),
      ),
      data: (day) {
        final times = {
          'Fajr': day.fajr,
          'Shuruk': day.shuruk,
          'Dhohr': day.dhohr,
          'Asr': day.asr,
          'Maghrib': day.maghrib,
          'Isha': day.isha,
        };

        final List<Widget> rows = [];
        for (var i = 0; i < _prayerOrder.length; i++) {
          final name = _prayerOrder[i];
          final time = times[name]!;
          final isCurrent = name == currentPrayerName;
          final isPassed = _isPassed(time, name, currentPrayerName);
          final isUpcoming = !isPassed && !isCurrent;

          rows.add(
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
              decoration: isCurrent
                  ? const BoxDecoration(color: _activeBg)
                  : null,
              child: Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w500 : null,
                      color: isPassed
                          ? const Color(0xFFBBBBBB)
                          : isCurrent
                          ? _dark
                          : _grey333,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isPassed)
                    const Icon(Icons.check, size: 14, color: _grey888),
                  if (isCurrent)
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
                  if (isUpcoming)
                    Text(
                      _timeRemaining(time),
                      style: const TextStyle(fontSize: 11, color: _grey888),
                    ),
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w500 : null,
                      color: isPassed
                          ? const Color(0xFFCCCCCC)
                          : isCurrent
                          ? _dark
                          : _grey555,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          );

          if (i < _prayerOrder.length - 1) {
            rows.add(
              const Divider(height: 1, thickness: 0.5, color: _dividerMedium),
            );
          }
        }

        return Card(child: Column(children: rows));
      },
    );
  }

  static bool _isPassed(String time, String name, String? current) {
    if (name == current) return false;
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final parts = time.split(':');
    final prayerMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    return prayerMin < nowMin;
  }

  static String _timeRemaining(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    final prayerTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final diff = prayerTime.difference(now);
    if (diff.isNegative) return '';
    final hours = diff.inHours;
    if (hours > 0) return '${hours}h';
    return '${diff.inMinutes}m';
  }
}
