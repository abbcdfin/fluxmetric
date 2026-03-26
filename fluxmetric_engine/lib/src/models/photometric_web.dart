import 'dart:math' as math;
import 'ies_data.dart';

/// Represents a 3D photometric web based on IES data.
/// Provides methods to query intensity ($I$) at any given vector.
class PhotometricWeb {
  final IesData data;

  PhotometricWeb(this.data);

  /// Returns the luminous intensity (in candelas) for a given direction.
  ///
  /// [theta] Vertical angle in degrees (0 is straight down, 90 is horizontal, 180 is straight up).
  /// [phi] Horizontal angle in degrees (0 to 360).
  double getIntensityAt(double theta, double phi) {
    // Normalize phi to [0, 360)
    double normPhi = phi % 360.0;
    if (normPhi < 0) normPhi += 360.0;

    // Handle horizontal symmetry (0-90, 0-180)
    double lookupPhi = normPhi;
    final maxPhi = data.horizontalAngles.last;
    if (maxPhi == 90.0) {
      // Quadrant symmetric
      lookupPhi = (normPhi % 90.0);
      int quadrant = (normPhi / 90.0).floor();
      if (quadrant % 2 != 0) lookupPhi = 90.0 - lookupPhi;
    } else if (maxPhi == 180.0) {
      // Bilateral symmetric
      if (normPhi > 180.0) lookupPhi = 360.0 - normPhi;
    }

    // Step 1: Find surrounding vertical angles
    int v1 = _findLowerIndex(data.verticalAngles, theta);
    int v2 = (v1 + 1 < data.numberOfVerticalAngles) ? v1 + 1 : v1;

    // Step 2: Find surrounding horizontal angles
    int h1 = _findLowerIndex(data.horizontalAngles, lookupPhi);
    int h2 = (h1 + 1 < data.numberOfHorizontalAngles) ? h1 + 1 : h1;

    // Step 3: Bilinear interpolation
    double t1 = data.verticalAngles[v1];
    double t2 = data.verticalAngles[v2];
    double p1 = data.horizontalAngles[h1];
    double p2 = data.horizontalAngles[h2];

    double q11 = data.candelaValues[h1][v1];
    double q12 = data.candelaValues[h1][v2];
    double q21 = data.candelaValues[h2][v1];
    double q22 = data.candelaValues[h2][v2];

    double intensity = _bilinearInterpolate(
      theta, lookupPhi,
      t1, t2, p1, p2,
      q11, q12, q21, q22,
    );

    return intensity * data.candelaMultiplier;
  }

  int _findLowerIndex(List<double> list, double value) {
    if (value <= list.first) return 0;
    if (value >= list.last) return list.length - 2 >= 0 ? list.length - 2 : 0;

    // Simple linear search (for small IES angle lists, this is efficient enough)
    for (int i = 0; i < list.length - 1; i++) {
      if (value >= list[i] && value <= list[i + 1]) return i;
    }
    return 0;
  }

  double _bilinearInterpolate(
    double t, double p,
    double t1, double t2, double p1, double p2,
    double q11, double q12, double q21, double q22,
  ) {
    if (t2 == t1 && p2 == p1) return q11;
    if (t2 == t1) return _linearInterpolate(p, p1, p2, q11, q21);
    if (p2 == p1) return _linearInterpolate(t, t1, t2, q11, q12);

    double r1 = _linearInterpolate(t, t1, t2, q11, q12);
    double r2 = _linearInterpolate(t, t1, t2, q21, q22);

    return _linearInterpolate(p, p1, p2, r1, r2);
  }

  double _linearInterpolate(double x, double x1, double x2, double y1, double y2) {
    if (x2 == x1) return y1;
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
  }

  /// Converts a relative direction vector to spherical coordinates (theta, phi).
  ///
  /// [vector] Direction from fixture to point.
  /// Returns a map with 'theta' and 'phi' in degrees.
  static Map<String, double> vectorToSpherical(math.Point<double> horizontal, double vertical) {
    // In our coordinate system:
    // - Nadir (straight down) is along the negative Z-axis.
    // - Theta = 0 at Nadir.
    // - Theta = 180 at Zenith.

    double distance = math.sqrt(horizontal.x * horizontal.x + horizontal.y * horizontal.y + vertical * vertical);
    if (distance == 0) return {'theta': 0.0, 'phi': 0.0};

    // cos(theta) = (-vertical) / distance (since vertical is Z and Nadir is -Z)
    // Wait, if Z is up, then Nadir is -Z.
    // Vector V = (x, y, z). Nadir is (0, 0, -1).
    // Angle between V and (0, 0, -1) is theta.
    // V . (0, 0, -1) = |V| |(0,0,-1)| cos(theta)
    // -z = distance * cos(theta)
    // cos(theta) = -z / distance
    double cosTheta = -vertical / distance;
    cosTheta = cosTheta.clamp(-1.0, 1.0);
    double theta = math.acos(cosTheta) * 180.0 / math.pi;

    // Phi is the angle in the XY plane.
    double phi = math.atan2(horizontal.y, horizontal.x) * 180.0 / math.pi;
    if (phi < 0) phi += 360.0;

    return {'theta': theta, 'phi': phi};
  }
}
