import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:fluxmetric_engine/src/models/ies_data.dart';
import 'package:fluxmetric_engine/src/models/photometric_web.dart';
import 'package:fluxmetric_engine/src/parser/ies_parser.dart';
import 'package:fluxmetric_engine/src/engine/point_by_point_engine.dart';

void main() {
  group('IesParser', () {
    test('Parses minimal symmetric IES content correctly', () {
      const sampleIes = """
IESNA:LM-63-2002
[TEST] Sample Test
[MANUFAC] Gemini CLI
TILT=NONE
1 1000 1 5 1 1 2 0.1 0.1 0
1 1 0
0 22.5 45 67.5 90
0
100 90 80 70 60
""";
      final data = IesParser.parse(sampleIes);

      expect(data.keywords['TEST'], equals('Sample Test'));
      expect(data.numberOfLamps, equals(1));
      expect(data.lumensPerLamp, equals(1000.0));
      expect(data.numberOfVerticalAngles, equals(5));
      expect(data.numberOfHorizontalAngles, equals(1));
      expect(data.verticalAngles, equals([0.0, 22.5, 45.0, 67.5, 90.0]));
      expect(data.horizontalAngles, equals([0.0]));
      expect(data.candelaValues[0], equals([100.0, 90.0, 80.0, 70.0, 60.0]));
    });
  });

  group('PhotometricWeb', () {
    final data = IesData(
      keywords: {},
      numberOfLamps: 1,
      lumensPerLamp: 1000,
      candelaMultiplier: 1.0,
      numberOfVerticalAngles: 3,
      numberOfHorizontalAngles: 1,
      photometricType: 1,
      unitType: 2,
      width: 0.1,
      length: 0.1,
      height: 0.0,
      ballastFactor: 1.0,
      ballastLampFactor: 1.0,
      inputWatts: 10,
      verticalAngles: [0.0, 45.0, 90.0],
      horizontalAngles: [0.0],
      candelaValues: [
        [100.0, 80.0, 0.0]
      ],
    );
    final web = PhotometricWeb(data);

    test('Interpolates intensity correctly between vertical angles', () {
      expect(web.getIntensityAt(0, 0), equals(100.0));
      expect(web.getIntensityAt(22.5, 0), equals(90.0)); // Midpoint between 0 and 45
      expect(web.getIntensityAt(45, 0), equals(80.0));
      expect(web.getIntensityAt(67.5, 0), equals(40.0)); // Midpoint between 45 and 90
      expect(web.getIntensityAt(90, 0), equals(0.0));
    });

    test('Converts vector to spherical coordinates correctly', () {
      // Nadir is (0, 0, -1) relative to fixture.
      // Fixture at (0,0,10), Point at (0,0,0) -> Vector (0, 0, -10).
      final spherical = PhotometricWeb.vectorToSpherical(const math.Point(0, 0), -10.0);
      expect(spherical['theta'], closeTo(0.0, 0.001));

      // Horizontal ray: Fixture at (0,0,0), Point at (10,0,0) -> Vector (10, 0, 0).
      final spherical2 = PhotometricWeb.vectorToSpherical(const math.Point(10, 0), 0.0);
      expect(spherical2['theta'], closeTo(90.0, 0.001));
      expect(spherical2['phi'], closeTo(0.0, 0.001));
    });
  });

  group('PointByPointEngine', () {
    test('Calculates Lux correctly for a simple single fixture', () {
      final data = IesData(
        keywords: {},
        numberOfLamps: 1,
        lumensPerLamp: -1, // Absolute
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
      final fixture = LightFixture(
        id: 'F1',
        position: const math.Point(0.0, 0.0),
        height: 10.0,
        web: web,
      );

      // Point directly below fixture at height 0.
      // d = 10m, theta = 0, Intensity = 1000 cd.
      // E = 1000 / 10^2 = 10 lux.
      // cos(alpha) = 10 / 10 = 1.
      // Eh = 10 lux.
      final lux = PointByPointEngine.calculateHorizontalIlluminance(
        const math.Point(0.0, 0.0),
        0.0,
        [fixture],
      );

      expect(lux, closeTo(10.0, 0.001));
    });
  });
}
