import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vector;
import '../models/photometric_web.dart';

/// Represents a light fixture in 3D space.
class LightFixture {
  final String id;
  final math.Point<double> position;
  final double height; // Z-coordinate
  final PhotometricWeb web;
  
  /// Tilt around the X-axis in degrees (0 is straight down).
  final double tilt;
  
  /// Rotation around the Z-axis (Pan) in degrees.
  final double rotation;

  LightFixture({
    required this.id,
    required this.position,
    required this.height,
    required this.web,
    this.tilt = 0.0,
    this.rotation = 0.0,
  });

  LightFixture copyWith({
    String? id,
    math.Point<double>? position,
    double? height,
    PhotometricWeb? web,
    double? tilt,
    double? rotation,
  }) {
    return LightFixture(
      id: id ?? this.id,
      position: position ?? this.position,
      height: height ?? this.height,
      web: web ?? this.web,
      tilt: tilt ?? this.tilt,
      rotation: rotation ?? this.rotation,
    );
  }
}

/// Core engine for Point-by-Point lighting calculations.
class PointByPointEngine {
  /// Calculates the horizontal illuminance (Lux) at a specific point.
  ///
  /// [point] Calculation point (X, Y) in global space.
  /// [z] Height of the calculation point (Work Plane) in global space.
  /// [fixtures] List of light fixtures in the scene.
  static double calculateHorizontalIlluminance(
    math.Point<double> point,
    double z,
    List<LightFixture> fixtures,
  ) {
    double totalLux = 0.0;

    for (var fixture in fixtures) {
      // 1. Calculate relative vector from fixture to point in global space.
      // dx, dy are horizontal offsets.
      // dz is the vertical offset from fixture down to plane.
      double dx = point.x - fixture.position.x;
      double dy = point.y - fixture.position.y;
      double dz = z - fixture.height; 

      double distanceSquared = dx * dx + dy * dy + dz * dz;
      double distance = math.sqrt(distanceSquared);

      if (distance < 0.001) continue;
      
      // If the plane is above the fixture (dz > 0), the top of the plane receives no light
      // from a downward-facing fixture.
      if (dz >= 0) continue;

      // 2. Transform the vector into the fixture's local coordinate system.
      // Global -> Local: Rotate by -rotation around Z, then -tilt around X.
      // We use the global relative vector (dx, dy, dz).
      var vGlobal = vector.Vector3(dx, dy, dz);
      
      final radRot = -fixture.rotation * math.pi / 180.0;
      final radTilt = -fixture.tilt * math.pi / 180.0;
      
      // Inverse Pan (Z)
      final mRot = vector.Matrix3.rotationZ(radRot);
      var vLocal = mRot.transformed(vGlobal);
      
      // Inverse Tilt (X)
      final mTilt = vector.Matrix3.rotationX(radTilt);
      vLocal = mTilt.transformed(vLocal);

      // 3. Convert local vector to spherical coordinates for IES lookup.
      // In our spherical system:
      // theta = 0 is Nadir (local -Z).
      // vertical = vLocal.z.
      // cosTheta = -vLocal.z / distance.
      // If vLocal.z is negative (downwards), cosTheta is positive, theta is near 0.
      final spherical = PhotometricWeb.vectorToSpherical(math.Point(vLocal.x, vLocal.y), vLocal.z);
      
      // 4. Get intensity in that direction from IES data.
      double intensity = fixture.web.getIntensityAt(spherical['theta']!, spherical['phi']!);

      // 5. Apply Inverse Square Law: E = I / d^2.
      double illuminanceAtPoint = intensity / distanceSquared;

      // 6. Apply Lambert's Cosine Law for horizontal plane: E_h = E * cos(alpha).
      // alpha is the angle between the light ray and the surface normal (0, 0, 1).
      // Ray vector from point to light is V_ray = (-dx, -dy, -dz).
      // cos(alpha) = (V_ray . Normal) / |V_ray| = -dz / distance.
      // Since dz is negative (point below light), -dz is positive.
      double cosAlpha = -dz / distance;
      
      totalLux += illuminanceAtPoint * cosAlpha;
    }

    return totalLux;
  }
}
