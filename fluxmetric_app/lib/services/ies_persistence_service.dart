import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/ies_library_entry.dart';
import 'package:ditredi/ditredi.dart';
import 'package:fluxmetric_engine/fluxmetric_engine.dart';

class IesPersistenceService {
  static const String _fileName = 'ies_library.json';

  Future<File> _getLibraryFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  Future<void> saveLibrary(List<IesLibraryEntry> entries) async {
    try {
      final file = await _getLibraryFile();
      final jsonList = entries.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print('Error saving IES library: $e');
    }
  }

  Future<List<IesLibraryEntry>> loadLibrary(List<Line3D> Function(IesData) webGenerator) async {
    try {
      final file = await _getLibraryFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((j) => IesLibraryEntry.fromJson(j as Map<String, dynamic>, webGenerator)).toList();
    } catch (e) {
      print('Error loading IES library: $e');
      return [];
    }
  }
}
