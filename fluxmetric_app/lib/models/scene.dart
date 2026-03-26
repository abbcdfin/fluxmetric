import 'package:fluxmetric_engine/fluxmetric_engine.dart';

/// Represents the overall state of a lighting simulation scene.
class Scene {
  final List<LightFixture> fixtures;
  final double workPlaneHeight;
  final String projectName;

  Scene({
    required this.fixtures,
    required this.workPlaneHeight,
    required this.projectName,
  });

  Scene copyWith({
    List<LightFixture>? fixtures,
    double? workPlaneHeight,
    String? projectName,
  }) {
    return Scene(
      fixtures: fixtures ?? this.fixtures,
      workPlaneHeight: workPlaneHeight ?? this.workPlaneHeight,
      projectName: projectName ?? this.projectName,
    );
  }
}
