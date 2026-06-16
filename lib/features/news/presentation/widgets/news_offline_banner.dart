import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewsOfflineBanner extends StatelessWidget {
  final String lastUpdated;

  const NewsOfflineBanner({super.key, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    final formatted = _format(lastUpdated);
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colors.errorContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.cloud_off,
              size: 16,
              color: colors.onErrorContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visar sparad version',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Senast uppdaterad: $formatted',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onErrorContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _format(String iso) {
    try {
      final date = DateTime.parse(iso);
      return DateFormat('d MMMM y', 'sv').format(date);
    } catch (_) {
      return iso;
    }
  }
}
