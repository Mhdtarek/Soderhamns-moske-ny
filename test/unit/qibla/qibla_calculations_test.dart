import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/features/qibla/providers/qibla_providers.dart';

void main() {
  group('calculateBearing', () {
    test('stockholm to kaaba is about 148 degrees', () {
      // soderhamn area roughly
      final bearing = calculateBearing(61.30, 17.10, 21.4225, 39.8262);
      // kaaba is southeast of sweden so bearing should be around 140 to 155
      expect(bearing, greaterThan(130));
      expect(bearing, lessThan(160));
    });

    test('point directly south of kaaba bearing is near zero', () {
      // point south of kaaba same longitude looking north
      final bearing = calculateBearing(21.3, 39.8262, 21.4225, 39.8262);
      expect(bearing, lessThan(4));
    });
  });

  group('calculateDistance', () {
    test('stockholm to kaaba is about 4500 to 5500 km', () {
      final distance = calculateDistance(59.33, 18.07, 21.4225, 39.8262);
      expect(distance, greaterThan(4000));
      expect(distance, lessThan(6000));
    });

    test('makkah to kaaba is near zero km', () {
      final distance = calculateDistance(21.42, 39.82, 21.4225, 39.8262);
      expect(distance, lessThan(1));
    });
  });

  group('calculateNeedleRotation', () {
    test('bearing 148 heading 90 gives 58', () {
      final rotation = calculateNeedleRotation(148, 90);
      expect(rotation, closeTo(58, 0.5));
    });

    test('bearing less than heading wraps around', () {
      final rotation = calculateNeedleRotation(10, 350);
      // 10 minus 350 plus 360 modulo 360 equals 20
      expect(rotation, closeTo(20, 0.5));
    });
  });
}