import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

/// Represents the results of a lux calculation grid.
class GridResult {
  final List<List<double>> values; // [y][x]
  final double min;
  final double max;
  final double average;
  final double uniformity; // E_min / E_avg

  GridResult({
    required this.values,
    required this.min,
    required this.max,
    required this.average,
    required this.uniformity,
  });
}

class CalculationViewModel extends ChangeNotifier {
  GridResult? _result;
  List<Face3D> _heatmapFaces = [];
  bool _isCalculating = false;

  bool _isDynamicScale = true;
  double _fixedMaxLux = 1000.0;

  // Store last calculation parameters for re-rendering
  double _lastWidth = 0;
  double _lastLength = 0;
  double _lastResolution = 0;
  double _lastWorkPlaneHeight = 0;

  GridResult? get result => _result;
  List<Face3D> get heatmapFaces => _heatmapFaces;
  bool get isCalculating => _isCalculating;
  bool get isDynamicScale => _isDynamicScale;
  double get fixedMaxLux => _fixedMaxLux;

  void setScaleSettings(bool isDynamic, double fixedMax) {
    _isDynamicScale = isDynamic;
    _fixedMaxLux = fixedMax;
    if (_result != null) {
      _generateHeatmapMesh(_lastWidth, _lastLength, _lastResolution, _lastWorkPlaneHeight);
    }
    notifyListeners();
  }

  Future<void> runCalculation({
    required List<LightFixture> fixtures,
    required double workPlaneHeight,
    required double width,
    required double length,
    required double resolution, // m per point
  }) async {
    _isCalculating = true;
    _lastWidth = width;
    _lastLength = length;
    _lastResolution = resolution;
    _lastWorkPlaneHeight = workPlaneHeight;
    notifyListeners();

    try {
      _result = _calculateGrid({
        'fixtures': fixtures,
        'workPlaneHeight': workPlaneHeight,
        'width': width,
        'length': length,
        'resolution': resolution,
      });

      _generateHeatmapMesh(width, length, resolution, workPlaneHeight);
    } catch (e) {
      debugPrint('Calculation error: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  void _generateHeatmapMesh(double width, double length, double resolution, double workPlaneHeight) {
    if (_result == null) return;
    
    _heatmapFaces = [];
    final rows = _result!.values.length;
    final cols = _result!.values[0].length;
    final startX = -width / 2;
    final startY = -length / 2;
    final h = workPlaneHeight + 0.01;

    final effectiveMax = _isDynamicScale ? _result!.max : _fixedMaxLux;

    for (int r = 0; r < rows - 1; r++) {
      for (int c = 0; c < cols - 1; c++) {
        final v1 = _result!.values[r][c];
        final v2 = _result!.values[r][c+1];
        final v3 = _result!.values[r+1][c+1];
        final v4 = _result!.values[r+1][c];

        final p1 = vector.Vector3(startX + c * resolution, startY + r * resolution, h);
        final p2 = vector.Vector3(startX + (c+1) * resolution, startY + r * resolution, h);
        final p3 = vector.Vector3(startX + (c+1) * resolution, startY + (r+1) * resolution, h);
        final p4 = vector.Vector3(startX + c * resolution, startY + (r+1) * resolution, h);

        final color = _luxToColor((v1 + v2 + v3 + v4) / 4, effectiveMax);

        _heatmapFaces.add(Face3D(vector.Triangle.points(p1, p2, p3), color: color));
        _heatmapFaces.add(Face3D(vector.Triangle.points(p1, p3, p4), color: color));
        _heatmapFaces.add(Face3D(vector.Triangle.points(p1, p3, p2), color: color));
        _heatmapFaces.add(Face3D(vector.Triangle.points(p1, p4, p3), color: color));
      }
    }
  }

  Color _luxToColor(double lux, double maxLux) {
    if (maxLux <= 0) return Colors.blue;
    final double normalized = (lux / maxLux).clamp(0.0, 1.0);
    return HSVColor.fromAHSV(1.0, (1.0 - normalized) * 240.0, 1.0, 1.0).toColor();
  }

  static GridResult _calculateGrid(Map<String, dynamic> params) {
    final List<LightFixture> fixtures = params['fixtures'];
    final double workPlaneHeight = params['workPlaneHeight'];
    final double width = params['width'];
    final double length = params['length'];
    final double resolution = params['resolution'];

    final int cols = (width / resolution).ceil() + 1;
    final int rows = (length / resolution).ceil() + 1;
    final startX = -width / 2;
    final startY = -length / 2;

    final List<List<double>> values = List.generate(rows, (_) => List.filled(cols, 0.0));
    double sum = 0;
    double min = double.infinity;
    double max = 0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final point = math.Point(startX + c * resolution, startY + r * resolution);
        final lux = PointByPointEngine.calculateHorizontalIlluminance(point, workPlaneHeight, fixtures);
        
        values[r][c] = lux;
        sum += lux;
        if (lux < min) min = lux;
        if (lux > max) max = lux;
      }
    }

    final average = sum / (rows * cols);
    final uniformity = average > 0 ? min / average : 0.0;

    return GridResult(
      values: values,
      min: min,
      max: max,
      average: average,
      uniformity: uniformity,
    );
  }
}
