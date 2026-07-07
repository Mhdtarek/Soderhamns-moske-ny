import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:soderhamns_moske_app/core/config/constants.dart';

// bearing from one point to another in degrees 0 to 360
double calculateBearing(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  final toRad = pi / 180;
  final toDeg = 180 / pi;

  final lat1r = lat1 * toRad;
  final lat2r = lat2 * toRad;
  final dLon = (lon2 - lon1) * toRad;

  final y = sin(dLon) * cos(lat2r);
  final x = cos(lat1r) * sin(lat2r) -
      sin(lat1r) * cos(lat2r) * cos(dLon);

  final bearing = atan2(y, x) * toDeg;
  return (bearing + 360) % 360;
}

// haversine distance in km
double calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const r = 6371; // earth radius km
  final toRad = pi / 180;

  final dLat = (lat2 - lat1) * toRad;
  final dLon = (lon2 - lon1) * toRad;

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * toRad) * cos(lat2 * toRad) *
          sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

// how much the needle should rotate from top
double calculateNeedleRotation(double bearing, double heading) {
  return (bearing - heading + 360) % 360;
}

// permission status for qibla screen
enum QiblaPermissionStatus {
  loading,
  locationDisabled,
  denied,
  deniedForever,
  granted,
}

// checks service and permission then requests if needed
final permissionProvider =
    FutureProvider<QiblaPermissionStatus>((ref) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return QiblaPermissionStatus.locationDisabled;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  switch (permission) {
    case LocationPermission.denied:
      return QiblaPermissionStatus.denied;
    case LocationPermission.deniedForever:
      return QiblaPermissionStatus.deniedForever;
    case LocationPermission.whileInUse:
    case LocationPermission.always:
      return QiblaPermissionStatus.granted;
    case LocationPermission.unableToDetermine:
      return QiblaPermissionStatus.denied;
  }
});

// one shot gps read only runs when permission is granted
final locationProvider = FutureProvider<Position>((ref) async {
  final status = ref.watch(permissionProvider).valueOrNull;
  if (status != QiblaPermissionStatus.granted) {
    throw Exception('permission not granted');
  }
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
});

// magnetometer stream converted to heading degrees with smoothing
final compassHeadingProvider = StreamProvider.autoDispose<double>((ref) {
  final controller = StreamController<double>();
  double? smoothed;

  final sub = magnetometerEventStream(
    samplingPeriod: const Duration(milliseconds: 20),
  ).listen(
    (event) {
      // phone flat screen up azimuth from north clockwise
      final raw = atan2(event.x, event.y) * 180 / pi;
      final normalized = (raw + 360) % 360;

      if (smoothed == null) {
        smoothed = normalized;
      } else {
        smoothed = smoothed! * 0.9 + normalized * 0.1;
      }
      controller.add(smoothed!);
    },
    // swallow errors silently so app doesnt crash
    // heading just stays null and screen shows compass unavailable
    onError: (error) {
      controller.close();
    },
  );

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

// bearing to kaaba from current location
final qiblaBearingProvider = Provider<double>((ref) {
  final pos = ref.watch(locationProvider).valueOrNull;
  if (pos == null) return 0;
  return calculateBearing(
    pos.latitude,
    pos.longitude,
    AppConstants.kaabaLatitude,
    AppConstants.kaabaLongitude,
  );
});

// distance to kaaba from current location
final qiblaDistanceProvider = Provider<double>((ref) {
  final pos = ref.watch(locationProvider).valueOrNull;
  if (pos == null) return 0;
  return calculateDistance(
    pos.latitude,
    pos.longitude,
    AppConstants.kaabaLatitude,
    AppConstants.kaabaLongitude,
  );
});

// final needle rotation combining bearing and heading
final needleRotationProvider = Provider<double>((ref) {
  final bearing = ref.watch(qiblaBearingProvider);
  final heading = ref.watch(compassHeadingProvider).valueOrNull ?? 0;
  return calculateNeedleRotation(bearing, heading);
});