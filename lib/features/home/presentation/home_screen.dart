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

    final dailyAyah = ref.watch(dailyAyahProvider);
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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _PrayerHeroCard(),
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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _PrayerListCard(),
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

class _PrayerHeroCard extends ConsumerWidget {
  const _PrayerHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = _Palette(Theme.of(context).brightness == Brightness.dark);
    final gregorianDate = ref.watch(gregorianDateProvider);
    final hijriDate = ref.watch(hijriDateProvider);
    final countdown = ref.watch(nextPrayerCountdownProvider);

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
                      style: TextStyle(fontSize: 12, color: c.faintText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hijriDate,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: c.mutedText,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: c.divider),
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
                onRetry: () => ref.invalidate(nextPrayerCountdownProvider),
              ),
              data: (cd) {
                final hasCurrent = cd.currentPrayerName != null;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasCurrent ? 'Aktuell bön' : 'Nästa bön',
                            style: TextStyle(
                              fontSize: 11,
                              color: c.faintText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasCurrent
                                ? cd.currentPrayerName!
                                : cd.nextPrayerName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              color: c.primaryText,
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
                        Opacity(
                          opacity: 0,
                          child: Text(
                            'Aktuell bön',
                            style: TextStyle(fontSize: 11, color: c.faintText),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCountdown(cd.remaining),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: c.accent,
                            fontFeatures: const [FontFeature.tabularFigures()],
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
          Divider(height: 1, thickness: 0.5, color: c.divider),
          // Zone 3 — Next prayers hint
          countdown.when(
            loading: () => const SizedBox(height: 36),
            error: (_, __) => const SizedBox.shrink(),
            data: (cd) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: c.tint),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: c.faintText),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: cd.nextPrayerName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: c.strongMuted,
                            ),
                          ),
                          TextSpan(
                            text: ' kl. ${cd.nextPrayerTime}',
                            style: TextStyle(
                              fontSize: 13,
                              color: c.mutedText,
                            ),
                          ),
                          TextSpan(
                            text: ', sedan ',
                            style: TextStyle(fontSize: 13, color: c.mutedText),
                          ),
                          TextSpan(
                            text: cd.nextNextPrayerName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: c.strongMuted,
                            ),
                          ),
                          TextSpan(
                            text: ' kl. ${cd.nextNextPrayerTime}',
                            style: TextStyle(
                              fontSize: 13,
                              color: c.mutedText,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = _Palette(isDark);
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
                        color: c.mutedText,
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
                        style: TextStyle(fontSize: 11, color: c.faintText),
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

class _PrayerListCard extends ConsumerWidget {
  const _PrayerListCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = _Palette(isDark);
    final todayTimes = ref.watch(todayPrayerTimesProvider);
    final countdown = ref.watch(nextPrayerCountdownProvider).valueOrNull;
    final currentPrayerName = countdown?.currentPrayerName;

    return todayTimes.when(
      loading: () =>
          Card(child: const SizedBox(height: 60, child: LoadingView())),
      error: (_, __) => Card(
        child: ErrorView(
          message: 'Kunde inte ladda bönetider',
          onRetry: () => ref.invalidate(todayPrayerTimesProvider),
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

        final passedColor = isDark ? const Color(0xFF6B6657) : const Color(0xFFBBBBBB);
        final passedTimeColor =
            isDark ? const Color(0xFF7A7567) : const Color(0xFFCCCCCC);

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
                  ? BoxDecoration(
                      color: c.gold.withValues(alpha: 0.15),
                      border: Border(
                        left: BorderSide(color: c.gold, width: 4),
                      ),
                    )
                  : null,
              child: Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w500 : null,
                      color: isPassed
                          ? passedColor
                          : isCurrent
                              ? c.primaryText
                              : c.strongMuted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isPassed)
                    Icon(Icons.check, size: 14, color: c.faintText),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.gold,
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
                      style: TextStyle(fontSize: 11, color: c.faintText),
                    ),
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w500 : null,
                      color: isPassed
                          ? passedTimeColor
                          : isCurrent
                              ? c.primaryText
                              : c.mutedText,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          );

          if (i < _prayerOrder.length - 1) {
            rows.add(
              Divider(height: 1, thickness: 0.5, color: c.dividerMedium),
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

class _Palette {
  final bool isDark;
  const _Palette(this.isDark);

  Color get primaryText =>
      isDark ? AppColors.darkText : const Color(0xFF2C2A22);
  Color get strongMuted => isDark ? const Color(0xFFC6BFAE) : const Color(0xFF333333);
  Color get mutedText => isDark ? const Color(0xFFAA9F8A) : const Color(0xFF555555);
  Color get faintText => isDark ? const Color(0xFF8A8578) : const Color(0xFF888888);
  Color get divider => isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000);
  Color get dividerMedium =>
      isDark ? const Color(0x12FFFFFF) : const Color(0x12000000);
  Color get tint => isDark ? const Color(0x05FFFFFF) : const Color(0x05000000);
  Color get gold => isDark ? AppColors.goldLight : AppColors.gold;
  Color get accent =>
      isDark ? AppColors.accentGreenLight : AppColors.accentGreen;
}
