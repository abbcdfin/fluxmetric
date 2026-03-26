import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import '../models/scene.dart';

class SimulationViewModel extends ChangeNotifier {
  Scene _scene = Scene(
    fixtures: [],
    workPlaneHeight: 0.8,
    width: 20.0,
    length: 20.0,
    projectName: 'Untitled Project',
  );
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

  void setWorkspaceSize(double width, double length) {
    _scene = _scene.copyWith(width: width, length: length);
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

  void selectAll() {
    _selectedFixtureIds.clear();
    for (var f in _scene.fixtures) {
      _selectedFixtureIds.add(f.id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedFixtureIds.clear();
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
    bool autoCenter = true,
    double startX = 0,
    double startY = 0,
  }) {
    final List<LightFixture> newFixtures = [];
    
    double x0 = startX;
    double y0 = startY;

    if (autoCenter) {
      // Calculate total grid size
      double gridWidth = (cols - 1) * colSpacing;
      double gridLength = (rows - 1) * rowSpacing;
      
      // Workspace coordinates: -width/2 to width/2
      // Center the grid around (0, 0)
      x0 = -gridWidth / 2;
      y0 = -gridLength / 2;
    }

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        newFixtures.add(
          LightFixture(
            id: 'grid_${r}_${c}_${DateTime.now().millisecondsSinceEpoch}',
            position: math.Point(x0 + c * colSpacing, y0 + r * rowSpacing),
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

  void updateSelectedPosition(double? x, double? y) {
    final updatedFixtures = _scene.fixtures.map((f) {
      if (_selectedFixtureIds.contains(f.id)) {
        return LightFixture(
          id: f.id,
          position: math.Point(x ?? f.position.x, y ?? f.position.y),
          height: f.height,
          web: f.web,
          tilt: f.tilt,
          rotation: f.rotation,
        );
      }
      return f;
    }).toList();
    
    _scene = _scene.copyWith(fixtures: updatedFixtures);
    notifyListeners();
  }

  void updateSelectedRotation(double? tilt, double? rotation) {
    final updatedFixtures = _scene.fixtures.map((f) {
      if (_selectedFixtureIds.contains(f.id)) {
        return f.copyWith(
          tilt: tilt,
          rotation: rotation,
        );
      }
      return f;
    }).toList();
    
    _scene = _scene.copyWith(fixtures: updatedFixtures);
    notifyListeners();
  }
}
