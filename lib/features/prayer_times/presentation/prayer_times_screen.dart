import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/core/theme/app_colors.dart';
import 'package:soderhamns_moske_app/data/models/prayer_day.dart';
import 'package:soderhamns_moske_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:soderhamns_moske_app/shared/widgets/error_view.dart';
import 'package:soderhamns_moske_app/shared/widgets/loading_view.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 1, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = _tabController.index;
    final asyncDay = ref.watch(dayByTabProvider(tabIndex));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bönetider'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Igår'),
            Tab(text: 'Idag'),
            Tab(text: 'Imorgon'),
          ],
        ),
      ),
      body: asyncDay.when(
        data: (day) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PrayerTimesCard(day: day, isToday: tabIndex == 1),
            const SizedBox(height: 16),
            const _WeekTable(),
            const SizedBox(height: 16),
            const _MonthTable(),
          ],
        ),
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: 'Kunde inte ladda bönetider',
          onRetry: () => ref.invalidate(dayByTabProvider(tabIndex)),
        ),
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
      final fajrParts = day.fajr.split(':');
      final shurukParts = day.shuruk.split(':');
      final dhohrParts = day.dhohr.split(':');
      final asrParts = day.asr.split(':');
      final maghribParts = day.maghrib.split(':');
      final ishaParts = day.isha.split(':');

      final fajrMin = int.parse(fajrParts[0]) * 60 + int.parse(fajrParts[1]);
      final shurukMin = int.parse(shurukParts[0]) * 60 + int.parse(shurukParts[1]);
      final dhohrMin = int.parse(dhohrParts[0]) * 60 + int.parse(dhohrParts[1]);
      final asrMin = int.parse(asrParts[0]) * 60 + int.parse(asrParts[1]);
      final maghribMin = int.parse(maghribParts[0]) * 60 + int.parse(maghribParts[1]);
      final ishaMin = int.parse(ishaParts[0]) * 60 + int.parse(ishaParts[1]);
      final nowMin = currentHour * 60 + currentMinute;

      if (nowMin >= fajrMin && nowMin < shurukMin) {
        currentPrayer = 'Fajr';
      } else if (nowMin >= dhohrMin && nowMin < asrMin) {
        currentPrayer = 'Dhohr';
      } else if (nowMin >= asrMin && nowMin < maghribMin) {
        currentPrayer = 'Asr';
      } else if (nowMin >= maghribMin && nowMin < ishaMin) {
        currentPrayer = 'Maghrib';
      } else if (nowMin >= ishaMin) {
        currentPrayer = 'Isha';
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PrayerRow(
              name: 'Fajr',
              time: day.fajr,
              status: _getStatus('Fajr', day.fajr, currentPrayer, isToday),
            ),
            const Divider(),
            _PrayerRow(
              name: 'Shuruk',
              time: day.shuruk,
              status: PrayerStatus.none,
            ),
            const Divider(),
            _PrayerRow(
              name: 'Dhohr',
              time: day.dhohr,
              status: _getStatus('Dhohr', day.dhohr, currentPrayer, isToday),
            ),
            const Divider(),
            _PrayerRow(
              name: 'Asr',
              time: day.asr,
              status: _getStatus('Asr', day.asr, currentPrayer, isToday),
            ),
            const Divider(),
            _PrayerRow(
              name: 'Maghrib',
              time: day.maghrib,
              status: _getStatus('Maghrib', day.maghrib, currentPrayer, isToday),
            ),
            const Divider(),
            _PrayerRow(
              name: 'Isha',
              time: day.isha,
              status: _getStatus('Isha', day.isha, currentPrayer, isToday),
            ),
          ],
        ),
      ),
    );
  }

  PrayerStatus _getStatus(String name, String time, String? currentPrayer, bool isToday) {
    if (!isToday) return PrayerStatus.none;
    if (currentPrayer == null) return PrayerStatus.upcoming;
    if (name == currentPrayer) return PrayerStatus.current;
    
    final prayers = ['Fajr', 'Shuruk', 'Dhohr', 'Asr', 'Maghrib', 'Isha'];
    final currentIndex = prayers.indexOf(currentPrayer);
    final thisIndex = prayers.indexOf(name);
    
    if (thisIndex < currentIndex) return PrayerStatus.passed;
    return PrayerStatus.upcoming;
  }
}

enum PrayerStatus { none, passed, current, upcoming }

class _PrayerRow extends StatelessWidget {
  final String name;
  final String time;
  final PrayerStatus status;

  const _PrayerRow({
    required this.name,
    required this.time,
    this.status = PrayerStatus.none,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = isDark ? AppColors.goldLight : AppColors.gold;
    final isCurrent = status == PrayerStatus.current;
    final isPassed = status == PrayerStatus.passed;
    final isUpcoming = status == PrayerStatus.upcoming;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: isCurrent
          ? BoxDecoration(
              color: highlightColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: highlightColor, width: 4),
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : null,
                      color: isPassed ? Colors.grey : null,
                    ),
              ),
              if (isPassed) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check, size: 16, color: Colors.grey),
              ],
              if (isCurrent) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: highlightColor,
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
              if (isUpcoming) ...[
                const SizedBox(width: 6),
                Text(
                  _getTimeRemaining(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : null,
                  color: isPassed ? Colors.grey : null,
                ),
          ),
        ],
      ),
    );
  }

  String _getTimeRemaining() {
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
    final minutes = diff.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h';
    }
    return '${minutes}m';
  }
}

class _WeekTable extends ConsumerStatefulWidget {
  const _WeekTable();

  @override
  ConsumerState<_WeekTable> createState() => _WeekTableState();
}

class _WeekTableState extends ConsumerState<_WeekTable> {
  late int _selectedWeek;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _selectedWeek = getIsoWeekNumber(DateTime.now());
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
                    'Veckovis',
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
                value: _selectedWeek,
                isExpanded: true,
                items: List.generate(getWeeksInYear(DateTime.now().year), (i) => i + 1)
                    .map((w) => DropdownMenuItem(
                          value: w,
                          child: Text('Vecka $w'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedWeek = v!),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _WeekData(week: _selectedWeek),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _WeekData extends ConsumerWidget {
  final int week;
  const _WeekData({required this.week});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDays = ref.watch(weekPrayerTimesProvider(week));
    return asyncDays.when(
      data: (days) {
        if (days.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Inga bönetider tillgängliga'),
          );
        }
        
        final now = DateTime.now();
        final weekYear = getIsoWeekYear(now);
        final monday = getMondayOfWeek(weekYear, week);
        const dayNames = ['Mån', 'Tis', 'Ons', 'Tor', 'Fre', 'Lör', 'Sön'];
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            columns: [
              const DataColumn(label: Text('Dag')),
              const DataColumn(label: Text('Fajr')),
              const DataColumn(label: Text('Shuruk')),
              const DataColumn(label: Text('Dhohr')),
              const DataColumn(label: Text('Asr')),
              const DataColumn(label: Text('Maghrib')),
              const DataColumn(label: Text('Isha')),
            ],
            rows: days.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              final dayDate = monday.add(Duration(days: i));
              final isToday = now.year == dayDate.year &&
                  now.month == dayDate.month &&
                  now.day == dayDate.day;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final highlightColor = isDark ? AppColors.goldLight : AppColors.gold;
              
              return DataRow(
                color: isToday
                    ? WidgetStatePropertyAll(
                        highlightColor.withValues(alpha: 0.15))
                    : null,
                cells: [
                  DataCell(Text(
                    '${dayNames[i]} ${d.date}/${dayDate.month}',
                    style: isToday
                        ? TextStyle(fontWeight: FontWeight.bold, color: highlightColor)
                        : null,
                  )),
                  DataCell(Text(d.fajr,
                      style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                  DataCell(Text(d.shuruk,
                      style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                  DataCell(Text(d.dhohr,
                      style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                  DataCell(Text(d.asr,
                      style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                  DataCell(Text(d.maghrib,
                      style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                  DataCell(Text(d.isha,
                      style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                ],
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingView(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: ErrorView(
          message: 'Kunde inte ladda bönetider',
          onRetry: () => ref.invalidate(weekPrayerTimesProvider(week)),
        ),
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
            SizedBox(
              width: double.infinity,
              child: _MonthData(month: _selectedMonth),
            ),
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
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final highlightColor = isDark ? AppColors.goldLight : AppColors.gold;
            return DataRow(
              color: isToday
                  ? WidgetStatePropertyAll(
                      highlightColor.withValues(alpha: 0.15))
                  : null,
              cells: [
                DataCell(Text('${d.date}',
                    style: isToday ? TextStyle(fontWeight: FontWeight.bold, color: highlightColor) : null)),
                DataCell(Text(d.fajr,
                    style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                DataCell(Text(d.shuruk,
                    style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                DataCell(Text(d.dhohr,
                    style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                DataCell(Text(d.asr,
                    style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                DataCell(Text(d.maghrib,
                    style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                DataCell(Text(d.isha,
                    style: isToday ? const TextStyle(fontWeight: FontWeight.bold) : null)),
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
