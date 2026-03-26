import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import '../models/scene.dart';

class SimulationViewModel extends ChangeNotifier {
  Scene _scene = Scene(fixtures: [], workPlaneHeight: 0.8, projectName: 'Untitled Project');
  final Set<String> _selectedFixtureIds = {};
  
  Scene get scene => _scene;
  List<LightFixture> get selectedFixtures => _scene.fixtures
      .where((f) => _selectedFixtureIds.contains(f.id))
      .toList();

  bool isSelected(String id) => _selectedFixtureIds.contains(id);

  void setWorkPlaneHeight(double height) {
    _scene = _scene.copyWith(workPlaneHeight: height);
    notifyListeners();
  }

  void toggleSelection(String id, {bool multi = false}) {
    if (!multi) _selectedFixtureIds.clear();
    
    if (_selectedFixtureIds.contains(id)) {
      _selectedFixtureIds.remove(id);
    } else {
      _selectedFixtureIds.add(id);
    }
    notifyListeners();
  }

  void addFixture(LightFixture fixture) {
    final updatedFixtures = List<LightFixture>.from(_scene.fixtures)..add(fixture);
    _scene = _scene.copyWith(fixtures: updatedFixtures);
    notifyListeners();
  }

  void removeSelected() {
    final updatedFixtures = _scene.fixtures
        .where((f) => !_selectedFixtureIds.contains(f.id))
        .toList();
    _scene = _scene.copyWith(fixtures: updatedFixtures);
    _selectedFixtureIds.clear();
    notifyListeners();
  }

  /// Parametric placement: generates a grid array of fixtures.
  void createGridArray({
    required PhotometricWeb web,
    required int rows,
    required int cols,
    required double rowSpacing,
    required double colSpacing,
    required double height,
    double startX = 0,
    double startY = 0,
  }) {
    final List<LightFixture> newFixtures = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        newFixtures.add(
          LightFixture(
            id: 'grid_${r}_${c}_${DateTime.now().millisecondsSinceEpoch}',
            position: math.Point(startX + c * colSpacing, startY + r * rowSpacing),
            height: height,
            web: web,
          ),
        );
      }
    }
    
    final updatedFixtures = List<LightFixture>.from(_scene.fixtures)..addAll(newFixtures);
    _scene = _scene.copyWith(fixtures: updatedFixtures);
    notifyListeners();
  }

  void updateSelectedHeight(double newHeight) {
    final updatedFixtures = _scene.fixtures.map((f) {
      if (_selectedFixtureIds.contains(f.id)) {
        return LightFixture(
          id: f.id,
          position: f.position,
          height: newHeight,
          web: f.web,
        );
      }
      return f;
    }).toList();
    
    _scene = _scene.copyWith(fixtures: updatedFixtures);
    notifyListeners();
  }
}
