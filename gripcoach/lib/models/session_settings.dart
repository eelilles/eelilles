import '../config/constants.dart';

/// User-configurable session settings
class SessionSettings {
  /// Road condition: 'dry', 'wet', 'snow', 'ice'
  final String roadCondition;

  /// Driver experience level: 'new', 'intermediate', 'experienced'
  final String driverLevel;

  /// Unit system: 'metric' or 'imperial'
  final String units;

  /// Grade percentage: -12 to +12
  final double gradePercent;

  /// View mode: 'bars' or 'distance'
  final String viewMode;

  /// Whether auto-grade estimation is enabled
  final bool autoGrade;

  const SessionSettings({
    this.roadCondition = 'dry',
    this.driverLevel = 'new',
    this.units = 'metric',
    this.gradePercent = 0.0,
    this.viewMode = 'bars',
    this.autoGrade = false,
  });

  /// Get friction coefficient for current road condition
  double get frictionMu => FRICTION_MU[roadCondition] ?? 0.80;

  /// Get safety factor for current driver level
  double get safetyFactor =>
      DRIVER_PROFILES[driverLevel]?['S'] ?? 0.55;

  /// Get reaction time for current driver level
  double get reactionTime =>
      DRIVER_PROFILES[driverLevel]?['t_react'] ?? 1.5;

  /// Get traction budget (mu_budget = mu_avail * S)
  double get tractionBudget => frictionMu * safetyFactor;

  /// Get road sensitivity multiplier for jerk detection
  double get roadSensitivity =>
      ROAD_SENSITIVITY[roadCondition] ?? 1.0;

  /// Get recommended following distance in seconds
  int get headwaySeconds =>
      HEADWAY_SECONDS[roadCondition] ?? 2;

  /// Check if units are metric
  bool get isMetric => units == 'metric';

  /// Get grade as decimal (grade_percent / 100)
  double get gradeDecimal => gradePercent / 100.0;

  /// Copy with new values
  SessionSettings copyWith({
    String? roadCondition,
    String? driverLevel,
    String? units,
    double? gradePercent,
    String? viewMode,
    bool? autoGrade,
  }) {
    return SessionSettings(
      roadCondition: roadCondition ?? this.roadCondition,
      driverLevel: driverLevel ?? this.driverLevel,
      units: units ?? this.units,
      gradePercent: gradePercent ?? this.gradePercent,
      viewMode: viewMode ?? this.viewMode,
      autoGrade: autoGrade ?? this.autoGrade,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'roadCondition': roadCondition,
      'driverLevel': driverLevel,
      'units': units,
      'gradePercent': gradePercent,
      'viewMode': viewMode,
      'autoGrade': autoGrade,
    };
  }

  /// Create from JSON map
  factory SessionSettings.fromJson(Map<String, dynamic> json) {
    return SessionSettings(
      roadCondition: json['roadCondition'] as String? ?? 'dry',
      driverLevel: json['driverLevel'] as String? ?? 'new',
      units: json['units'] as String? ?? 'metric',
      gradePercent: (json['gradePercent'] as num?)?.toDouble() ?? 0.0,
      viewMode: json['viewMode'] as String? ?? 'bars',
      autoGrade: json['autoGrade'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'SessionSettings(road: $roadCondition, driver: $driverLevel, '
        'units: $units, grade: $gradePercent%, viewMode: $viewMode, '
        'autoGrade: $autoGrade)';
  }
}
