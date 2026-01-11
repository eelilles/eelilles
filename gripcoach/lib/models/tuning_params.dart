import '../config/constants.dart';

/// Tunable parameters accessible via hidden dev screen
class TuningParams {
  // Smoothing time constants
  final double displayTauS;
  final double eventTauS;

  // Jerk thresholds
  final double jerkYawThreshold;
  final double jerkLatThreshold;
  final double jerkLongThreshold;
  final double deltaYawRateThreshold;

  // Speed thresholds for jerk detection
  final double jerkSteeringMinSpeedKmh;
  final double jerkBrakeMinSpeedKmh;

  // Motion lock thresholds
  final double motionLockSpeedKmh;
  final double motionUnlockSpeedKmh;
  final double motionUnlockDurationS;

  // Traction thresholds
  final double greenThreshold;
  final double yellowThreshold;
  final double colorHysteresis;
  final double tractionExceedanceDurationS;

  // Grade estimation
  final double gradeTauS;
  final double gradeMaxRate;
  final double steadyStateSpeedMinKmh;
  final double steadyStateAccelMaxG;
  final double steadyStateDurationS;

  // Road sensitivity multipliers (can be tuned)
  final Map<String, double> roadSensitivity;

  const TuningParams({
    this.displayTauS = DISPLAY_TAU_S,
    this.eventTauS = EVENT_TAU_S,
    this.jerkYawThreshold = JERK_YAW_THRESHOLD,
    this.jerkLatThreshold = JERK_LAT_THRESHOLD,
    this.jerkLongThreshold = JERK_LONG_THRESHOLD,
    this.deltaYawRateThreshold = DELTA_YAW_RATE_THRESHOLD,
    this.jerkSteeringMinSpeedKmh = JERK_STEERING_MIN_SPEED_KMH,
    this.jerkBrakeMinSpeedKmh = JERK_BRAKE_MIN_SPEED_KMH,
    this.motionLockSpeedKmh = MOTION_LOCK_SPEED_KMH,
    this.motionUnlockSpeedKmh = MOTION_UNLOCK_SPEED_KMH,
    this.motionUnlockDurationS = MOTION_UNLOCK_DURATION_S,
    this.greenThreshold = GREEN_THRESHOLD,
    this.yellowThreshold = YELLOW_THRESHOLD,
    this.colorHysteresis = COLOR_HYSTERESIS,
    this.tractionExceedanceDurationS = TRACTION_EXCEEDANCE_DURATION,
    this.gradeTauS = GRADE_TAU_S,
    this.gradeMaxRate = GRADE_MAX_RATE,
    this.steadyStateSpeedMinKmh = STEADY_STATE_SPEED_MIN_KMH,
    this.steadyStateAccelMaxG = STEADY_STATE_ACCEL_MAX_G,
    this.steadyStateDurationS = STEADY_STATE_DURATION_S,
    this.roadSensitivity = ROAD_SENSITIVITY,
  });

  /// Get effective jerk threshold for a road condition
  double getEffectiveJerkThreshold(double baseThreshold, String roadCondition) {
    final multiplier = roadSensitivity[roadCondition] ?? 1.0;
    return baseThreshold * multiplier;
  }

  /// Create default tuning params
  factory TuningParams.defaults() => const TuningParams();

  /// Copy with new values
  TuningParams copyWith({
    double? displayTauS,
    double? eventTauS,
    double? jerkYawThreshold,
    double? jerkLatThreshold,
    double? jerkLongThreshold,
    double? deltaYawRateThreshold,
    double? jerkSteeringMinSpeedKmh,
    double? jerkBrakeMinSpeedKmh,
    double? motionLockSpeedKmh,
    double? motionUnlockSpeedKmh,
    double? motionUnlockDurationS,
    double? greenThreshold,
    double? yellowThreshold,
    double? colorHysteresis,
    double? tractionExceedanceDurationS,
    double? gradeTauS,
    double? gradeMaxRate,
    double? steadyStateSpeedMinKmh,
    double? steadyStateAccelMaxG,
    double? steadyStateDurationS,
    Map<String, double>? roadSensitivity,
  }) {
    return TuningParams(
      displayTauS: displayTauS ?? this.displayTauS,
      eventTauS: eventTauS ?? this.eventTauS,
      jerkYawThreshold: jerkYawThreshold ?? this.jerkYawThreshold,
      jerkLatThreshold: jerkLatThreshold ?? this.jerkLatThreshold,
      jerkLongThreshold: jerkLongThreshold ?? this.jerkLongThreshold,
      deltaYawRateThreshold:
          deltaYawRateThreshold ?? this.deltaYawRateThreshold,
      jerkSteeringMinSpeedKmh:
          jerkSteeringMinSpeedKmh ?? this.jerkSteeringMinSpeedKmh,
      jerkBrakeMinSpeedKmh: jerkBrakeMinSpeedKmh ?? this.jerkBrakeMinSpeedKmh,
      motionLockSpeedKmh: motionLockSpeedKmh ?? this.motionLockSpeedKmh,
      motionUnlockSpeedKmh: motionUnlockSpeedKmh ?? this.motionUnlockSpeedKmh,
      motionUnlockDurationS:
          motionUnlockDurationS ?? this.motionUnlockDurationS,
      greenThreshold: greenThreshold ?? this.greenThreshold,
      yellowThreshold: yellowThreshold ?? this.yellowThreshold,
      colorHysteresis: colorHysteresis ?? this.colorHysteresis,
      tractionExceedanceDurationS:
          tractionExceedanceDurationS ?? this.tractionExceedanceDurationS,
      gradeTauS: gradeTauS ?? this.gradeTauS,
      gradeMaxRate: gradeMaxRate ?? this.gradeMaxRate,
      steadyStateSpeedMinKmh:
          steadyStateSpeedMinKmh ?? this.steadyStateSpeedMinKmh,
      steadyStateAccelMaxG: steadyStateAccelMaxG ?? this.steadyStateAccelMaxG,
      steadyStateDurationS: steadyStateDurationS ?? this.steadyStateDurationS,
      roadSensitivity: roadSensitivity ?? this.roadSensitivity,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'displayTauS': displayTauS,
      'eventTauS': eventTauS,
      'jerkYawThreshold': jerkYawThreshold,
      'jerkLatThreshold': jerkLatThreshold,
      'jerkLongThreshold': jerkLongThreshold,
      'deltaYawRateThreshold': deltaYawRateThreshold,
      'jerkSteeringMinSpeedKmh': jerkSteeringMinSpeedKmh,
      'jerkBrakeMinSpeedKmh': jerkBrakeMinSpeedKmh,
      'motionLockSpeedKmh': motionLockSpeedKmh,
      'motionUnlockSpeedKmh': motionUnlockSpeedKmh,
      'motionUnlockDurationS': motionUnlockDurationS,
      'greenThreshold': greenThreshold,
      'yellowThreshold': yellowThreshold,
      'colorHysteresis': colorHysteresis,
      'tractionExceedanceDurationS': tractionExceedanceDurationS,
      'gradeTauS': gradeTauS,
      'gradeMaxRate': gradeMaxRate,
      'steadyStateSpeedMinKmh': steadyStateSpeedMinKmh,
      'steadyStateAccelMaxG': steadyStateAccelMaxG,
      'steadyStateDurationS': steadyStateDurationS,
      'roadSensitivity': roadSensitivity,
    };
  }

  /// Create from JSON map
  factory TuningParams.fromJson(Map<String, dynamic> json) {
    return TuningParams(
      displayTauS: (json['displayTauS'] as num?)?.toDouble() ?? DISPLAY_TAU_S,
      eventTauS: (json['eventTauS'] as num?)?.toDouble() ?? EVENT_TAU_S,
      jerkYawThreshold:
          (json['jerkYawThreshold'] as num?)?.toDouble() ?? JERK_YAW_THRESHOLD,
      jerkLatThreshold:
          (json['jerkLatThreshold'] as num?)?.toDouble() ?? JERK_LAT_THRESHOLD,
      jerkLongThreshold: (json['jerkLongThreshold'] as num?)?.toDouble() ??
          JERK_LONG_THRESHOLD,
      deltaYawRateThreshold:
          (json['deltaYawRateThreshold'] as num?)?.toDouble() ??
              DELTA_YAW_RATE_THRESHOLD,
      jerkSteeringMinSpeedKmh:
          (json['jerkSteeringMinSpeedKmh'] as num?)?.toDouble() ??
              JERK_STEERING_MIN_SPEED_KMH,
      jerkBrakeMinSpeedKmh:
          (json['jerkBrakeMinSpeedKmh'] as num?)?.toDouble() ??
              JERK_BRAKE_MIN_SPEED_KMH,
      motionLockSpeedKmh: (json['motionLockSpeedKmh'] as num?)?.toDouble() ??
          MOTION_LOCK_SPEED_KMH,
      motionUnlockSpeedKmh:
          (json['motionUnlockSpeedKmh'] as num?)?.toDouble() ??
              MOTION_UNLOCK_SPEED_KMH,
      motionUnlockDurationS:
          (json['motionUnlockDurationS'] as num?)?.toDouble() ??
              MOTION_UNLOCK_DURATION_S,
      greenThreshold:
          (json['greenThreshold'] as num?)?.toDouble() ?? GREEN_THRESHOLD,
      yellowThreshold:
          (json['yellowThreshold'] as num?)?.toDouble() ?? YELLOW_THRESHOLD,
      colorHysteresis:
          (json['colorHysteresis'] as num?)?.toDouble() ?? COLOR_HYSTERESIS,
      tractionExceedanceDurationS:
          (json['tractionExceedanceDurationS'] as num?)?.toDouble() ??
              TRACTION_EXCEEDANCE_DURATION,
      gradeTauS: (json['gradeTauS'] as num?)?.toDouble() ?? GRADE_TAU_S,
      gradeMaxRate: (json['gradeMaxRate'] as num?)?.toDouble() ?? GRADE_MAX_RATE,
      steadyStateSpeedMinKmh:
          (json['steadyStateSpeedMinKmh'] as num?)?.toDouble() ??
              STEADY_STATE_SPEED_MIN_KMH,
      steadyStateAccelMaxG:
          (json['steadyStateAccelMaxG'] as num?)?.toDouble() ??
              STEADY_STATE_ACCEL_MAX_G,
      steadyStateDurationS:
          (json['steadyStateDurationS'] as num?)?.toDouble() ??
              STEADY_STATE_DURATION_S,
      roadSensitivity: json['roadSensitivity'] != null
          ? Map<String, double>.from(json['roadSensitivity'] as Map)
          : ROAD_SENSITIVITY,
    );
  }
}
