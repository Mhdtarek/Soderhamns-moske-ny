import 'dart:async';
import 'dart:math';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
  const r = 6371;
  final toRad = pi / 180;

  final dLat = (lat2 - lat1) * toRad;
  final dLon = (lon2 - lon1) * toRad;

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * toRad) * cos(lat2 * toRad) *
          sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

// angle between where youre facing and where kaaba is
// 0 means you are facing straight at it
double calculateNeedleRotation(double bearing, double heading) {
  return (bearing - heading + 360) % 360;
}

// magnetometer data with heading and interference flag
class CompassData {
  final double heading;
  final bool interference;

  const CompassData({required this.heading, required this.interference});
}

// permission status for qibla screen
enum QiblaPermissionStatus {
  loading,
  locationDisabled,
  denied,
  deniedForever,
  granted,
}

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

final locationProvider = FutureProvider<Position>((ref) async {
  final status = ref.watch(permissionProvider).valueOrNull;
  if (status != QiblaPermissionStatus.granted) {
    throw Exception('permission not granted');
  }
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
    ),
  );
});

// compass heading via flutter_compass (platform tilt-compensated
// true/magnetic heading) with shortest-arc smoothing to avoid
// jitter/spin across the 0/360 boundary.
final compassHeadingProvider =
    StreamProvider.autoDispose<CompassData>((ref) {
  final controller = StreamController<CompassData>();
  double? smoothed;
  StreamSubscription<CompassEvent>? sub;

  final stream = FlutterCompass.events;
  if (stream == null) {
    // compass hardware not available on this device
    controller.close();
    return controller.stream;
  }

  sub = stream.listen(
    (event) {
      final heading = event.heading;
      if (heading == null) {
        // android reports null when no sensor is available
        return;
      }
      final raw = (heading + 360) % 360;

      if (smoothed == null) {
        smoothed = raw;
      } else {
        // shortest angular difference so the dial takes the shorter
        // path around the circle even across 0/360
        final diff = ((raw - smoothed! + 540) % 360) - 180;
        smoothed = (smoothed! + diff * 0.2 + 360) % 360;
      }

      // accuracy is in degrees (iOS) / platform-dependent (android).
      // high value = unreliable, treat as magnetic interference.
      final acc = event.accuracy;
      final interference = acc != null && acc > 15;

      controller.add(CompassData(
        heading: smoothed!,
        interference: interference,
      ));
    },
    onError: (error) {
      controller.close();
    },
  );

  ref.onDispose(() {
    sub?.cancel();
    controller.close();
  });

  return controller.stream;
});

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