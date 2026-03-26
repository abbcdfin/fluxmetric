import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:fast_gbk/fast_gbk.dart';

class IesVisualizerViewModel extends ChangeNotifier {
  IesData? _iesData;
  PhotometricWeb? _photometricWeb;
  List<Line3D> _webLines = [];
  bool _isLoading = false;

  IesData? get iesData => _iesData;
  List<Line3D> get webLines => _webLines;
  bool get isLoading => _isLoading;

  Future<void> pickIesFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ies'],
    );

    if (result != null) {
      _isLoading = true;
      notifyListeners();

      try {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        String content;
        
        try {
          // Try UTF-8 first
          content = utf8.decode(bytes);
        } catch (_) {
          try {
            // Try GBK (common for Chinese IES files)
            content = gbk.decode(bytes);
          } catch (_) {
            // Final fallback to Latin-1
            content = latin1.decode(bytes);
          }
        }

        _iesData = IesParser.parse(content);
        _photometricWeb = PhotometricWeb(_iesData!);
        _generateWebLines();
      } catch (e) {
        debugPrint('Error parsing IES file: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _generateWebLines() {
    if (_iesData == null) return;

    _webLines = [];
    final data = _iesData!;
    const double scaleFactor = 0.01; // Scale candela to a reasonable visual size

    // 1. Vertical slices (constant phi)
    for (int h = 0; h < data.numberOfHorizontalAngles; h++) {
      final phi = data.horizontalAngles[h];
      for (int v = 0; v < data.numberOfVerticalAngles - 1; v++) {
        final t1 = data.verticalAngles[v];
        final t2 = data.verticalAngles[v+1];
        
        final i1 = data.candelaValues[h][v] * scaleFactor;
        final i2 = data.candelaValues[h][v+1] * scaleFactor;

        final p1 = _sphericalToCartesian(t1, phi, i1);
        final p2 = _sphericalToCartesian(t2, phi, i2);

        _webLines.add(Line3D(p1, p2, color: Colors.blue.withOpacity(0.5)));
      }
    }

    // 2. Horizontal rings (constant theta)
    if (data.numberOfHorizontalAngles > 1) {
      for (int v = 0; v < data.numberOfVerticalAngles; v++) {
        final theta = data.verticalAngles[v];
        for (int h = 0; h < data.numberOfHorizontalAngles - 1; h++) {
          final p1_phi = data.horizontalAngles[h];
          final p2_phi = data.horizontalAngles[h+1];

          final i1 = data.candelaValues[h][v] * scaleFactor;
          final i2 = data.candelaValues[h+1][v] * scaleFactor;

          final p1 = _sphericalToCartesian(theta, p1_phi, i1);
          final p2 = _sphericalToCartesian(theta, p2_phi, i2);

          _webLines.add(Line3D(p1, p2, color: Colors.blue.withOpacity(0.3)));
        }
        
        if (data.horizontalAngles.last - data.horizontalAngles.first >= 359) {
           final p1_phi = data.horizontalAngles.last;
           final p2_phi = data.horizontalAngles.first;
           final i1 = data.candelaValues.last[v] * scaleFactor;
           final i2 = data.candelaValues.first[v] * scaleFactor;
           final p1 = _sphericalToCartesian(theta, p1_phi, i1);
           final p2 = _sphericalToCartesian(theta, p2_phi, i2);
           _webLines.add(Line3D(p1, p2, color: Colors.blue.withOpacity(0.3)));
        }
      }
    }
  }

  vector.Vector3 _sphericalToCartesian(double thetaDeg, double phiDeg, double r) {
    final theta = thetaDeg * 3.14159 / 180.0;
    final phi = phiDeg * 3.14159 / 180.0;

    final z = -r * math.cos(theta);
    final rHorizontal = r * math.sin(theta);
    final x = rHorizontal * math.cos(phi);
    final y = rHorizontal * math.sin(phi);

    return vector.Vector3(x, y, z);
  }
}
