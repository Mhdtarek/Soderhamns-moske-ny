import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/shared/providers/connectivity_provider.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      data: (isOnline) {
        if (isOnline) return const SizedBox.shrink();
        final colors = Theme.of(context).colorScheme;
        return Container(
          color: colors.errorContainer,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 16, right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 14,
                  color: colors.onErrorContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ingen internetanslutning',
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
