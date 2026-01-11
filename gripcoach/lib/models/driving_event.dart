/// Types of driving events that can be detected
enum DrivingEventType {
  /// Sudden/jerky steering input
  steeringJerk,

  /// Sudden/jerky braking or acceleration
  brakeJerk,

  /// Traction budget exceeded (combined_frac > 1.0 for >0.3s)
  tractionExceedance,
}

/// A single driving event detected during a session
class DrivingEvent {
  /// Type of event
  final DrivingEventType type;

  /// When the event occurred
  final DateTime timestamp;

  /// Speed at time of event (km/h)
  final double speedKmh;

  /// Longitudinal acceleration at time of event (m/s²)
  final double aLong;

  /// Lateral acceleration at time of event (m/s²)
  final double aLat;

  /// Grade at time of event (%)
  final double gradePercent;

  /// Combined traction fraction at time of event
  final double combinedFrac;

  /// Jerk value that triggered the event (if applicable)
  final double? jerkValue;

  /// Road condition at time of event
  final String roadCondition;

  /// Driver level at time of event
  final String driverLevel;

  const DrivingEvent({
    required this.type,
    required this.timestamp,
    required this.speedKmh,
    required this.aLong,
    required this.aLat,
    required this.gradePercent,
    required this.combinedFrac,
    this.jerkValue,
    required this.roadCondition,
    required this.driverLevel,
  });

  /// Get human-readable event type name
  String get typeName {
    switch (type) {
      case DrivingEventType.steeringJerk:
        return 'Jerky Steering';
      case DrivingEventType.brakeJerk:
        return 'Jerky Braking';
      case DrivingEventType.tractionExceedance:
        return 'Traction Limit Exceeded';
    }
  }

  /// Get teaching explanation for the event
  String get explanation {
    switch (type) {
      case DrivingEventType.steeringJerk:
        return 'Sudden steering inputs can cause loss of control, '
            'especially on $roadCondition roads. Practice smoother, '
            'gradual steering movements.';
      case DrivingEventType.brakeJerk:
        return 'Sudden braking can lock wheels or trigger ABS unnecessarily. '
            'Practice progressive brake pressure for smoother stops.';
      case DrivingEventType.tractionExceedance:
        return 'You used more grip than available for the conditions. '
            'This could cause sliding on $roadCondition surfaces. '
            'Reduce speed or inputs in similar situations.';
    }
  }

  /// Get severity level (1-3)
  int get severity {
    if (type == DrivingEventType.tractionExceedance) return 3;
    if (combinedFrac > 0.9) return 2;
    return 1;
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'speedKmh': speedKmh,
      'aLong': aLong,
      'aLat': aLat,
      'gradePercent': gradePercent,
      'combinedFrac': combinedFrac,
      'jerkValue': jerkValue,
      'roadCondition': roadCondition,
      'driverLevel': driverLevel,
    };
  }

  /// Create from JSON map
  factory DrivingEvent.fromJson(Map<String, dynamic> json) {
    return DrivingEvent(
      type: DrivingEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DrivingEventType.steeringJerk,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      speedKmh: (json['speedKmh'] as num).toDouble(),
      aLong: (json['aLong'] as num).toDouble(),
      aLat: (json['aLat'] as num).toDouble(),
      gradePercent: (json['gradePercent'] as num).toDouble(),
      combinedFrac: (json['combinedFrac'] as num).toDouble(),
      jerkValue: (json['jerkValue'] as num?)?.toDouble(),
      roadCondition: json['roadCondition'] as String,
      driverLevel: json['driverLevel'] as String,
    );
  }

  @override
  String toString() {
    return 'DrivingEvent($typeName at ${timestamp.toIso8601String()}, '
        'speed: ${speedKmh.toStringAsFixed(1)} km/h)';
  }
}
