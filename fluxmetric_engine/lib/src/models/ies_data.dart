/// Represents the raw data parsed from an IES (LM-63) file.
class IesData {
  /// Metadata keywords found in the IES file.
  final Map<String, String> keywords;

  /// Total number of lamps.
  final int numberOfLamps;

  /// Lumens per lamp. -1 indicates absolute photometry.
  final double lumensPerLamp;

  /// Multiplier for all candela values.
  final double candelaMultiplier;

  /// Number of vertical angles.
  final int numberOfVerticalAngles;

  /// Number of horizontal angles.
  final int numberOfHorizontalAngles;

  /// Photometric type (1: Type C, 2: Type B, 3: Type A).
  final int photometricType;

  /// Unit type (1: Feet, 2: Meters).
  final int unitType;

  /// Width of the luminous opening.
  final double width;

  /// Length of the luminous opening.
  final double length;

  /// Height of the luminous opening.
  final double height;

  /// Ballast factor.
  final double ballastFactor;

  /// Ballast-lamp photometer factor.
  final double ballastLampFactor;

  /// Input watts.
  final double inputWatts;

  /// List of vertical angles in degrees.
  final List<double> verticalAngles;

  /// List of horizontal angles in degrees.
  final List<double> horizontalAngles;

  /// Candela values matrix [horizontalIndex][verticalIndex].
  final List<List<double>> candelaValues;

  IesData({
    required this.keywords,
    required this.numberOfLamps,
    required this.lumensPerLamp,
    required this.candelaMultiplier,
    required this.numberOfVerticalAngles,
    required this.numberOfHorizontalAngles,
    required this.photometricType,
    required this.unitType,
    required this.width,
    required this.length,
    required this.height,
    required this.ballastFactor,
    required this.ballastLampFactor,
    required this.inputWatts,
    required this.verticalAngles,
    required this.horizontalAngles,
    required this.candelaValues,
  });

  /// Total lumens calculated from the IES data (if not absolute).
  double get totalLumens => lumensPerLamp * numberOfLamps;

  /// Whether the photometry is absolute.
  bool get isAbsolute => lumensPerLamp == -1;
}
