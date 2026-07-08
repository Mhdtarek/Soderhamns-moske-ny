import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:soderhamns_moske_app/core/theme/app_colors.dart';
import 'package:soderhamns_moske_app/features/qibla/presentation/widgets/compass_widget.dart';
import 'package:soderhamns_moske_app/features/qibla/providers/qibla_providers.dart';
import 'package:soderhamns_moske_app/l10n/app_localizations.dart';

const _dark = Color(0xFF2C2A22);
const _grey888 = Color(0xFF888888);
const _grey555 = Color(0xFF555555);
const _green = Color(0xFF4A7C59);

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final permission = ref.watch(permissionProvider);
    final location = ref.watch(locationProvider);
    final bearing = ref.watch(qiblaBearingProvider);
    final distance = ref.watch(qiblaDistanceProvider);
    final compass = ref.watch(compassHeadingProvider);

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
        loading: () => _LoadingView(text: l.qiblaLocating),
        error: (_, __) => _LoadingView(text: l.errorLoading),
        data: (status) => _body(
          status: status,
          location: location,
          l: l,
          bearing: bearing,
          distance: distance,
          compass: compass.valueOrNull,
        ),
      ),
    );
  }

  Widget _body({
    required QiblaPermissionStatus status,
    required AsyncValue<Position> location,
    required AppLocalizations l,
    required double bearing,
    required double distance,
    required CompassData? compass,
  }) {
    switch (status) {
      case QiblaPermissionStatus.loading:
        return _LoadingView(text: l.qiblaLocating);
      case QiblaPermissionStatus.locationDisabled:
        return _InfoView(
          icon: Icons.location_off,
          title: l.qiblaLocationDisabled,
          message: l.qiblaLocationDisabledMessage,
          buttonText: l.qiblaOpenSettings,
          action: Geolocator.openAppSettings,
        );
      case QiblaPermissionStatus.denied:
      case QiblaPermissionStatus.deniedForever:
        return _InfoView(
          icon: Icons.location_disabled,
          title: l.qiblaPermissionDenied,
          message: l.qiblaPermissionMessage,
          buttonText: l.qiblaOpenSettings,
          action: Geolocator.openAppSettings,
        );
      case QiblaPermissionStatus.granted:
        if (compass == null) {
          return _InfoView(
            icon: Icons.explore_off,
            title: l.qiblaUnavailable,
            message: l.qiblaUnavailableMessage,
          );
        }
        return location.when(
          loading: () => _LoadingView(text: l.qiblaLocating),
          error: (_, __) => _LoadingView(text: l.errorLoading),
          data: (pos) => _ActiveCompass(
            l: l,
            heading: compass.heading,
            bearing: bearing,
            distance: distance,
            accuracy: pos.accuracy,
            interference: compass.interference,
          ),
        );
    }
  }
}

class _ActiveCompass extends StatelessWidget {
  const _ActiveCompass({
    required this.l,
    required this.heading,
    required this.bearing,
    required this.distance,
    required this.accuracy,
    required this.interference,
  });

  final AppLocalizations l;
  final double heading;
  final double bearing;
  final double distance;
  final double accuracy;
  final bool interference;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lowAccuracy = accuracy > 25;

    // angular delta from current heading to qibla, shortest side
    final delta = (bearing - heading + 360) % 360;
    final deviation = delta > 180 ? 360 - delta : delta;
    final turnRight = delta <= 180; // clockwise turn needed
    final aligned = deviation < 5;

    final turnValue = aligned
        ? l.qiblaAligned
        : (turnRight
            ? '${deviation.round()}° ↻'
            : '↺ ${deviation.round()}°');

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CompassWidget(
                heading: heading,
                bearing: bearing,
              ),
              const SizedBox(height: 28),

              // bearing block
              Column(
                children: [
                  Text(
                    l.qiblaBearing,
                    style: TextStyle(
                      fontSize: 12,
                      color: _grey888,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bearing.round()}°',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      color: isDark ? AppColors.darkText : _dark,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // distance + turn-to-align inline cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: l.qiblaDistance,
                      value: '${_formatDistance(distance)} km',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: l.qiblaTurn,
                      value: turnValue,
                      isDark: isDark,
                      accent: aligned ? AppColors.gold : null,
                    ),
                  ),
                ],
              ),

              if (lowAccuracy) ...[
                const SizedBox(height: 16),
                _WarningBanner(
                  text: l.qiblaLowAccuracy,
                  icon: Icons.warning_amber_rounded,
                  color: Colors.amber,
                ),
              ],

              if (interference) ...[
                const SizedBox(height: 16),
                _WarningBanner(
                  text: l.qiblaInterference,
                  icon: Icons.blur_on,
                  color: Colors.red,
                ),
              ],

              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 14,
                    color: _grey888,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l.qiblaCalibrate,
                      style: TextStyle(
                        fontSize: 12,
                        color: _grey888,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double km) {
    return NumberFormat('#,##0.0', 'sv').format(km);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.isDark,
    this.accent,
  });

  final String label;
  final String value;
  final bool isDark;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent?.withValues(alpha: 0.12) ??
            (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent?.withValues(alpha: 0.4) ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: _grey888,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: accent ?? (isDark ? AppColors.darkText : _dark),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color.shade700),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoView extends StatelessWidget {
  const _InfoView({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 36, color: AppColors.gold),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkText
                        : _dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: _grey555,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && action != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: action,
                icon: const Icon(Icons.settings, size: 18),
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(buttonText!),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: _grey888,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}