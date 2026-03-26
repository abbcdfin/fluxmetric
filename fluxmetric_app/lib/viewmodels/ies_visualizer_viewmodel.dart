import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:fast_gbk/fast_gbk.dart';
import '../models/ies_library_entry.dart';
import '../services/ies_persistence_service.dart';

class IesVisualizerViewModel extends ChangeNotifier {
  final List<IesLibraryEntry> _library = [];
  int _selectedIndex = -1;
  bool _isLoading = false;
  final _persistence = IesPersistenceService();

  IesVisualizerViewModel() {
    _loadLibrary();
  }

  List<IesLibraryEntry> get library => _library;
  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;

  IesLibraryEntry? get selectedEntry => 
      (_selectedIndex >= 0 && _selectedIndex < _library.length) ? _library[_selectedIndex] : null;

  IesData? get iesData => selectedEntry?.data;
  List<Line3D> get webLines => selectedEntry?.webLines ?? [];

  Future<void> _loadLibrary() async {
    _isLoading = true;
    notifyListeners();
    final entries = await _persistence.loadLibrary(_generateWebLines);
    _library.addAll(entries);
    if (_library.isNotEmpty) _selectedIndex = 0;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveLibrary() async {
    await _persistence.saveLibrary(_library);
  }

  void selectEntry(int index) {
    if (index >= -1 && index < _library.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void removeEntry(int index) {
    if (index >= 0 && index < _library.length) {
      _library.removeAt(index);
      if (_selectedIndex >= _library.length) {
        _selectedIndex = _library.length - 1;
      }
      _saveLibrary();
      notifyListeners();
    }
  }

  void renameEntry(int index, String newName) {
    if (index >= 0 && index < _library.length) {
      _library[index] = _library[index].copyWith(displayName: newName);
      _saveLibrary();
      notifyListeners();
    }
  }

  Future<void> pickIesFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ies'],
      allowMultiple: true,
    );

    if (result != null) {
      _isLoading = true;
      notifyListeners();

      try {
        for (var fileInfo in result.files) {
          final file = File(fileInfo.path!);
          final bytes = await file.readAsBytes();
          String content;
          
          try {
            content = utf8.decode(bytes);
          } catch (_) {
            try {
              content = gbk.decode(bytes);
            } catch (_) {
              content = latin1.decode(bytes);
            }
          }

          final data = IesParser.parse(content);
          final entry = IesLibraryEntry(
            id: 'ies_${DateTime.now().millisecondsSinceEpoch}_${fileInfo.name}',
            fileName: fileInfo.name,
            displayName: fileInfo.name, // Default to file name
            rawContent: content,
            data: data,
            webLines: _generateWebLines(data),
          );
          
          _library.add(entry);
        }
        
        if (_selectedIndex == -1 && _library.isNotEmpty) {
          _selectedIndex = _library.length - 1;
        }
        _saveLibrary();
      } catch (e) {
        debugPrint('Error parsing IES file: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  List<Line3D> _generateWebLines(IesData data) {
    final List<Line3D> lines = [];
    const double scaleFactor = 0.01;

    for (int h = 0; h < data.numberOfHorizontalAngles; h++) {
      final phi = data.horizontalAngles[h];
      for (int v = 0; v < data.numberOfVerticalAngles - 1; v++) {
        final t1 = data.verticalAngles[v];
        final t2 = data.verticalAngles[v+1];
        final i1 = data.candelaValues[h][v] * scaleFactor;
        final i2 = data.candelaValues[h][v+1] * scaleFactor;
        final p1 = _sphericalToCartesian(t1, phi, i1);
        final p2 = _sphericalToCartesian(t2, phi, i2);
        lines.add(Line3D(p1, p2, color: Colors.blue.withOpacity(0.5)));
      }
    }

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
          lines.add(Line3D(p1, p2, color: Colors.blue.withOpacity(0.3)));
        }
        if (data.horizontalAngles.last - data.horizontalAngles.first >= 359) {
           final p1_phi = data.horizontalAngles.last;
           final p2_phi = data.horizontalAngles.first;
           final i1 = data.candelaValues.last[v] * scaleFactor;
           final i2 = data.candelaValues.first[v] * scaleFactor;
           final p1 = _sphericalToCartesian(theta, p1_phi, i1);
           final p2 = _sphericalToCartesian(theta, p2_phi, i2);
           lines.add(Line3D(p1, p2, color: Colors.blue.withOpacity(0.3)));
        }
      }
    }
    return lines;
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
