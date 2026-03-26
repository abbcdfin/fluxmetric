import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import 'package:ditredi/ditredi.dart';

/// Represents an entry in the IES Library.
class IesLibraryEntry {
  final String id;
  final String fileName;
  final String displayName;
  final String rawContent;
  final IesData data;
  final List<Line3D> webLines;

  IesLibraryEntry({
    required this.id,
    required this.fileName,
    required this.displayName,
    required this.rawContent,
    required this.data,
    required this.webLines,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'displayName': displayName,
      'rawContent': rawContent,
    };
  }

  factory IesLibraryEntry.fromJson(Map<String, dynamic> json, List<Line3D> Function(IesData) webGenerator) {
    final rawContent = json['rawContent'] as String;
    final data = IesParser.parse(rawContent);
    return IesLibraryEntry(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      displayName: json['displayName'] as String,
      rawContent: rawContent,
      data: data,
      webLines: webGenerator(data),
    );
  }

  IesLibraryEntry copyWith({
    String? displayName,
  }) {
    return IesLibraryEntry(
      id: id,
      fileName: fileName,
      displayName: displayName ?? this.displayName,
      rawContent: rawContent,
      data: data,
      webLines: webLines,
    );
  }
}
