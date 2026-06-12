import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';
import 'package:soderhamns_moske_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:soderhamns_moske_app/shared/widgets/error_view.dart';
import 'package:soderhamns_moske_app/shared/widgets/loading_view.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bönetider'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Igår'),
              Tab(text: 'Idag'),
              Tab(text: 'Imorgon'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _YesterdayTab(),
            _TodayTab(),
            _TomorrowTab(),
          ],
        ),
      ),
    );
  }
}

class _YesterdayTab extends ConsumerWidget {
  const _YesterdayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDay = ref.watch(yesterdayPrayerTimesProvider);
    return asyncDay.when(
      data: (day) => _PrayerTimesCard(day: day),
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: 'Kunde inte ladda bönetider',
        onRetry: () => ref.invalidate(yesterdayPrayerTimesProvider),
      ),
    );
  }
}

class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDay = ref.watch(todayPrayerTimesProvider);
    return asyncDay.when(
      data: (day) => _PrayerTimesCard(day: day, isToday: true),
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: 'Kunde inte ladda bönetider',
        onRetry: () => ref.invalidate(todayPrayerTimesProvider),
      ),
    );
  }
}

class _TomorrowTab extends ConsumerWidget {
  const _TomorrowTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDay = ref.watch(tomorrowPrayerTimesProvider);
    return asyncDay.when(
      data: (day) => _PrayerTimesCard(day: day),
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: 'Kunde inte ladda bönetider',
        onRetry: () => ref.invalidate(tomorrowPrayerTimesProvider),
      ),
    );
  }
}

class _PrayerTimesCard extends StatelessWidget {
  final PrayerDay day;
  final bool isToday;

  const _PrayerTimesCard({required this.day, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    String? currentPrayer;
    if (isToday) {
      final prayers = [
        ('Fajr', day.fajr),
        ('Shuruk', day.shuruk),
        ('Dhohr', day.dhohr),
        ('Asr', day.asr),
        ('Maghrib', day.maghrib),
        ('Isha', day.isha),
      ];
      for (int i = prayers.length - 1; i >= 0; i--) {
        final parts = prayers[i].$2.split(':');
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        if (currentHour > h || (currentHour == h && currentMinute >= m)) {
          currentPrayer = prayers[i].$1;
          break;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _PrayerRow(
                  name: 'Fajr',
                  time: day.fajr,
                  isHighlighted: currentPrayer == 'Fajr',
                ),
                const Divider(),
                _PrayerRow(
                  name: 'Shuruk',
                  time: day.shuruk,
                  isHighlighted: currentPrayer == 'Shuruk',
                ),
                const Divider(),
                _PrayerRow(
                  name: 'Dhohr',
                  time: day.dhohr,
                  isHighlighted: currentPrayer == 'Dhohr',
                ),
                const Divider(),
                _PrayerRow(
                  name: 'Asr',
                  time: day.asr,
                  isHighlighted: currentPrayer == 'Asr',
                ),
                const Divider(),
                _PrayerRow(
                  name: 'Maghrib',
                  time: day.maghrib,
                  isHighlighted: currentPrayer == 'Maghrib',
                ),
                const Divider(),
                _PrayerRow(
                  name: 'Isha',
                  time: day.isha,
                  isHighlighted: currentPrayer == 'Isha',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _MonthTable(),
      ],
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String name;
  final String time;
  final bool isHighlighted;

  const _PrayerRow({
    required this.name,
    required this.time,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: isHighlighted
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleMedium),
          Text(time, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _MonthTable extends ConsumerStatefulWidget {
  const _MonthTable();

  @override
  ConsumerState<_MonthTable> createState() => _MonthTableState();
}

class _MonthTableState extends ConsumerState<_MonthTable> {
  late int _selectedMonth;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Månadsvis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<int>(
                value: _selectedMonth,
                isExpanded: true,
                items: List.generate(12, (i) => i + 1)
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(_monthName(m)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedMonth = v!),
              ),
            ),
            const SizedBox(height: 8),
            _MonthData(month: _selectedMonth),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Januari', 'Februari', 'Mars', 'April', 'Maj', 'Juni',
      'Juli', 'Augusti', 'September', 'Oktober', 'November', 'December',
    ];
    return names[m - 1];
  }
}

class _MonthData extends ConsumerWidget {
  final int month;
  const _MonthData({required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDays = ref.watch(monthPrayerTimesProvider(month));
    return asyncDays.when(
      data: (days) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('Dag')),
            DataColumn(label: Text('Fajr')),
            DataColumn(label: Text('Shuruk')),
            DataColumn(label: Text('Dhohr')),
            DataColumn(label: Text('Asr')),
            DataColumn(label: Text('Maghrib')),
            DataColumn(label: Text('Isha')),
          ],
          rows: days.map((d) {
            final isToday = DateTime.now().month == month &&
                DateTime.now().day == d.date;
            return DataRow(
              color: isToday
                  ? WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primaryContainer)
                  : null,
              cells: [
                DataCell(Text('${d.date}')),
                DataCell(Text(d.fajr)),
                DataCell(Text(d.shuruk)),
                DataCell(Text(d.dhohr)),
                DataCell(Text(d.asr)),
                DataCell(Text(d.maghrib)),
                DataCell(Text(d.isha)),
              ],
            );
          }).toList(),
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingView(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: ErrorView(
          message: 'Kunde inte ladda bönetider',
          onRetry: () => ref.invalidate(monthPrayerTimesProvider(month)),
        ),
      ),
    );
  }
}
