import 'dart:math' as math;
import '../models/photometric_web.dart';

/// Represents a light fixture in 3D space.
class LightFixture {
  final String id;
  final math.Point<double> position;
  final double height; // Z-coordinate
  final PhotometricWeb web;
  
  // Future: Add rotation/tilt/pan

  LightFixture({
    required this.id,
    required this.position,
    required this.height,
    required this.web,
  });
}

/// Core engine for Point-by-Point lighting calculations.
class PointByPointEngine {
  /// Calculates the horizontal illuminance (Lux) at a specific point.
  ///
  /// [point] Calculation point (X, Y).
  /// [z] Height of the calculation point (Work Plane).
  /// [fixtures] List of light fixtures in the scene.
  static double calculateHorizontalIlluminance(
    math.Point<double> point,
    double z,
    List<LightFixture> fixtures,
  ) {
    double totalLux = 0.0;

    for (var fixture in fixtures) {
      // 1. Calculate relative vector from fixture to point
      double dx = point.x - fixture.position.x;
      double dy = point.y - fixture.position.y;
      double dz = z - fixture.height; // Vertical distance (fixture to point)

      double distanceSquared = dx * dx + dy * dy + dz * dz;
      double distance = math.sqrt(distanceSquared);

      if (distance == 0) continue;

      // 2. Convert to spherical coordinates for IES lookup
      final spherical = PhotometricWeb.vectorToSpherical(math.Point(dx, dy), dz);
      
      // 3. Get intensity in that direction
      double intensity = fixture.web.getIntensityAt(spherical['theta']!, spherical['phi']!);

      // 4. Apply Inverse Square Law
      // E = I / d^2
      double illuminanceAtPoint = intensity / distanceSquared;

      // 5. Apply Lambert's Cosine Law for horizontal plane
      // E_h = E * cos(alpha)
      // alpha is the angle between the ray and the surface normal (0, 0, 1).
      // cos(alpha) = |V . N| / (|V| |N|) = |dz| / distance
      double cosAlpha = (dz.abs()) / distance;
      
      totalLux += illuminanceAtPoint * cosAlpha;
    }

    return totalLux;
  }
}
