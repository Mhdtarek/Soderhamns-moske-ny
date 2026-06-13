import 'package:flutter/material.dart';
import 'package:soderhamns_moske_app/core/theme/app_colors.dart';
import 'package:soderhamns_moske_app/shared/prayer_status.dart';

class PrayerRow extends StatelessWidget {
  final String name;
  final String time;
  final PrayerStatus status;

  const PrayerRow({
    super.key,
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
