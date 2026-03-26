import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:fluxmetric_engine/src/models/ies_data.dart';
import 'package:fluxmetric_engine/src/models/photometric_web.dart';
import 'package:fluxmetric_engine/src/engine/point_by_point_engine.dart';

void main() {
  group('Superposition Verification', () {
    test('Calculates Lux for multiple fixtures correctly', () {
      // Fixture: 1000cd at Nadir, 0cd at 90 deg
      final data = IesData(
        keywords: {},
        numberOfLamps: 1,
        lumensPerLamp: -1,
        candelaMultiplier: 1.0,
        numberOfVerticalAngles: 2,
        numberOfHorizontalAngles: 1,
        photometricType: 1,
        unitType: 2,
        width: 0.1,
        length: 0.1,
        height: 0.0,
        ballastFactor: 1.0,
        ballastLampFactor: 1.0,
        inputWatts: 100,
        verticalAngles: [0.0, 90.0],
        horizontalAngles: [0.0],
        candelaValues: [
          [1000.0, 0.0]
        ],
      );
      final web = PhotometricWeb(data);

      // Two fixtures at (0, 0, 10) and (10, 0, 10).
      final f1 = LightFixture(id: 'F1', position: const math.Point(0.0, 0.0), height: 10.0, web: web);
      final f2 = LightFixture(id: 'F2', position: const math.Point(10.0, 0.0), height: 10.0, web: web);

      // Calculation point exactly between them at (5, 0, 0).
      // For each fixture:
      // dx = 5, dy = 0, dz = -10.
      // distSq = 5^2 + 10^2 = 25 + 100 = 125.
      // dist = sqrt(125) = 11.18.
      // cosTheta = 10 / 11.18 = 0.8944.
      // theta = acos(0.8944) = 26.565 degrees.
      // Intensity at 26.565: linear between 1000(0) and 0(90).
      // I = 1000 - (26.565 / 90) * 1000 = 1000 - 295.17 = 704.83 cd.
      // E = 704.83 / 125 = 5.6386 lux.
      // Eh = 5.6386 * cos(alpha) = 5.6386 * (10 / 11.18) = 5.6386 * 0.8944 = 5.043 lux.
      // Total Eh = 2 * 5.043 = 10.086 lux.

      final lux = PointByPointEngine.calculateHorizontalIlluminance(
        const math.Point(5.0, 0.0),
        0.0,
        [f1, f2],
      );

      expect(lux, closeTo(10.086, 0.01));
    });
  });
}
