import '../models/ies_data.dart';

/// Parser for IES (LM-63) files.
class IesParser {
  /// Parses an IES file from its string content.
  static IesData parse(String content) {
    final tokens = _tokenize(content);
    int currentTokenIndex = 0;

    String nextToken() {
      if (currentTokenIndex >= tokens.length) return '';
      return tokens[currentTokenIndex++];
    }

    double nextDouble() => double.tryParse(nextToken()) ?? 0.0;
    int nextInt() => int.tryParse(nextToken()) ?? 0;

    // Step 1: Parse Keywords
    final keywords = <String, String>{};
    String firstLine = nextToken();
    if (firstLine != 'IESNA:LM-63-1986' &&
        firstLine != 'IESNA:LM-63-1991' &&
        firstLine != 'IESNA:LM-63-1995' &&
        firstLine != 'IESNA:LM-63-2002') {
      // Potentially skip early format identifiers if they are not explicitly present as first tokens
      // Some old files might not have the header. Re-check the first token.
    }

    while (currentTokenIndex < tokens.length) {
      final token = tokens[currentTokenIndex];
      if (token.startsWith('[')) {
        final closingIndex = token.indexOf(']');
        if (closingIndex != -1) {
          final key = token.substring(1, closingIndex);
          final value = token.substring(closingIndex + 1).trim();
          keywords[key] = value;
          currentTokenIndex++;
        } else {
          break;
        }
      } else if (token == 'TILT=NONE' || token == 'TILT=') {
        // TILT information starts here
        break;
      } else {
        // Stop keywords if we hit TILT
        break;
      }
    }

    // Step 2: Handle TILT line
    final tiltLine = nextToken();
    if (tiltLine.startsWith('TILT=INCLUDE')) {
      // Future improvement: Support TILT=INCLUDE
      // For now, we skip those tokens until we reach the main numeric block
      // In TILT=INCLUDE, we expect file name, orientation, number of angles, then pairs of angles/multipliers
    } else if (tiltLine == 'TILT=NONE') {
      // Standard case, continue
    }

    // Step 3: Parse Numeric Parameters
    final numberOfLamps = nextInt();
    final lumensPerLamp = nextDouble();
    final candelaMultiplier = nextDouble();
    final numberOfVerticalAngles = nextInt();
    final numberOfHorizontalAngles = nextInt();
    final photometricType = nextInt();
    final unitType = nextInt();
    final width = nextDouble();
    final length = nextDouble();
    final height = nextDouble();

    // Step 4: Parse Secondary Parameters
    final ballastFactor = nextDouble();
    final ballastLampFactor = nextDouble();
    final inputWatts = nextDouble();

    // Step 5: Parse Vertical Angles
    final verticalAngles = <double>[];
    for (int i = 0; i < numberOfVerticalAngles; i++) {
      verticalAngles.add(nextDouble());
    }

    // Step 6: Parse Horizontal Angles
    final horizontalAngles = <double>[];
    for (int i = 0; i < numberOfHorizontalAngles; i++) {
      horizontalAngles.add(nextDouble());
    }

    // Step 7: Parse Candela Values
    final candelaValues = <List<double>>[];
    for (int h = 0; h < numberOfHorizontalAngles; h++) {
      final verticalSlice = <double>[];
      for (int v = 0; v < numberOfVerticalAngles; v++) {
        verticalSlice.add(nextDouble());
      }
      candelaValues.add(verticalSlice);
    }

    return IesData(
      keywords: keywords,
      numberOfLamps: numberOfLamps,
      lumensPerLamp: lumensPerLamp,
      candelaMultiplier: candelaMultiplier,
      numberOfVerticalAngles: numberOfVerticalAngles,
      numberOfHorizontalAngles: numberOfHorizontalAngles,
      photometricType: photometricType,
      unitType: unitType,
      width: width,
      length: length,
      height: height,
      ballastFactor: ballastFactor,
      ballastLampFactor: ballastLampFactor,
      inputWatts: inputWatts,
      verticalAngles: verticalAngles,
      horizontalAngles: horizontalAngles,
      candelaValues: candelaValues,
    );
  }

  static List<String> _tokenize(String content) {
    // This simple split handles spaces, tabs, and newlines as delimiters.
    // However, it might struggle with quoted keywords.
    // We should be careful about keywords containing spaces if they aren't enclosed in brackets.
    // In LM-63, keywords are usually [KEYWORD] Value...
    // Let's refine the tokenization.
    final result = <String>[];
    final lines = content.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('[')) {
        // Keep the keyword line as a single token for simplicity
        result.add(line);
      } else {
        // Split by whitespace
        result.addAll(line.split(RegExp(r'\s+')));
      }
    }
    return result;
  }
}
