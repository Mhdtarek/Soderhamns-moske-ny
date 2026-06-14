import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/core/theme/app_colors.dart';
import 'package:soderhamns_moske_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:soderhamns_moske_app/shared/widgets/error_view.dart';
import 'package:soderhamns_moske_app/shared/widgets/loading_view.dart';
import 'package:soderhamns_moske_app/shared/widgets/prayer_times_card.dart';

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
          physics: Theme.of(context).platform == TargetPlatform.iOS
              ? const BouncingScrollPhysics()
              : null,
          padding: const EdgeInsets.all(16),
          children: [
            PrayerTimesCard(day: day, isToday: tabIndex == 1),
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
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<int>(
                    value: _selectedWeek,
                    isExpanded: true,
                    items: List.generate(
                        getWeeksInYear(DateTime.now().year), (i) => i + 1)
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
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
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
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
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
