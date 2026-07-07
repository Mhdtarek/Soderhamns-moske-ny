import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:soderhamns_moske_app/features/qibla/presentation/widgets/compass_widget.dart';
import 'package:soderhamns_moske_app/features/qibla/providers/qibla_providers.dart';
import 'package:soderhamns_moske_app/l10n/app_localizations.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final permission = ref.watch(permissionProvider);
    final location = ref.watch(locationProvider);
    final needleRotation = ref.watch(needleRotationProvider);
    final bearing = ref.watch(qiblaBearingProvider);
    final distance = ref.watch(qiblaDistanceProvider);
    final heading = ref.watch(compassHeadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.qibla),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l.qiblaRefresh,
            onPressed: () => ref.invalidate(locationProvider),
          ),
        ],
      ),
      body: permission.when(
        loading: () => _CenteredText(l.qiblaLocating),
        error: (_, __) => _CenteredText(l.errorLoading),
        data: (status) => _bodyForStatus(
          context,
          status,
          location,
          l,
          needleRotation,
          bearing,
          distance,
          heading.valueOrNull,
        ),
      ),
    );
  }

  Widget _bodyForStatus(
    BuildContext context,
    QiblaPermissionStatus status,
    AsyncValue<Position> location,
    AppLocalizations l,
    double needleRotation,
    double bearing,
    double distance,
    double? heading,
  ) {
    switch (status) {
      case QiblaPermissionStatus.loading:
        return _CenteredText(l.qiblaLocating);
      case QiblaPermissionStatus.locationDisabled:
        return _PermissionView(
          icon: Icons.location_off,
          title: l.qiblaLocationDisabled,
          message: l.qiblaLocationDisabledMessage,
          buttonText: l.qiblaOpenSettings,
        );
      case QiblaPermissionStatus.denied:
      case QiblaPermissionStatus.deniedForever:
        return _PermissionView(
          icon: Icons.location_disabled,
          title: l.qiblaPermissionDenied,
          message: l.qiblaPermissionMessage,
          buttonText: l.qiblaOpenSettings,
        );
      case QiblaPermissionStatus.granted:
        if (heading == null) {
          return _CenteredText(l.qiblaUnavailableMessage);
        }
        return location.when(
          loading: () => _CenteredText(l.qiblaLocating),
          error: (_, __) => _CenteredText(l.errorLoading),
          data: (pos) => _ActiveCompass(
            l: l,
            needleRotation: needleRotation,
            bearing: bearing,
            distance: distance,
            accuracy: pos.accuracy,
          ),
        );
    }
  }
}

// shown when compass is active
class _ActiveCompass extends StatelessWidget {
  const _ActiveCompass({
    required this.l,
    required this.needleRotation,
    required this.bearing,
    required this.distance,
    required this.accuracy,
  });

  final AppLocalizations l;
  final double needleRotation;
  final double bearing;
  final double distance;
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    final lowAccuracy = accuracy > 25;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CompassWidget(needleRotation: needleRotation),
              const SizedBox(height: 32),
              Text(
                l.qiblaBearing,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${bearing.round()}°',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Text(
                '${_formatDistance(distance)} ${l.qiblaDistance}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                l.qiblaAccuracy,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '±${accuracy.round()} m',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (lowAccuracy) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(l.qiblaLowAccuracy),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                l.qiblaCalibrate,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // format with swedish locale one decimal
  String _formatDistance(double km) {
    return NumberFormat('#,##0.0', 'sv').format(km);
  }
}

// permission or location disabled view with button
class _PermissionView extends StatelessWidget {
  const _PermissionView({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Geolocator.openAppSettings(),
              icon: const Icon(Icons.settings),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredText extends StatelessWidget {
  const _CenteredText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}