import 'package:fluxmetric_engine/fluxmetric_engine.dart';

/// Represents the overall state of a lighting simulation scene.
class Scene {
  final List<LightFixture> fixtures;
  final double workPlaneHeight;
  final double width;
  final double length;
  final String projectName;

  Scene({
    required this.fixtures,
    required this.workPlaneHeight,
    required this.width,
    required this.length,
    required this.projectName,
  });

  Scene copyWith({
    List<LightFixture>? fixtures,
    double? workPlaneHeight,
    double? width,
    double? length,
    String? projectName,
  }) {
    return Scene(
      fixtures: fixtures ?? this.fixtures,
      workPlaneHeight: workPlaneHeight ?? this.workPlaneHeight,
      width: width ?? this.width,
      length: length ?? this.length,
      projectName: projectName ?? this.projectName,
    );
  }
}
