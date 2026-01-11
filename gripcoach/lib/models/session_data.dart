import 'package:uuid/uuid.dart';

import 'calibration_data.dart';
import 'data_point.dart';
import 'driving_event.dart';
import 'session_settings.dart';

/// Complete data for a driving session
class SessionData {
  /// Unique session identifier
  final String id;

  /// Session settings at start
  final SessionSettings settings;

  /// Calibration data used for session
  final CalibrationData calibration;

  /// List of driving events detected
  final List<DrivingEvent> events;

  /// Downsampled data points (5-10 Hz)
  final List<DataPoint> dataPoints;

  /// Total time in green zone (seconds)
  final double greenTimeSeconds;

  /// Total time in yellow zone (seconds)
  final double yellowTimeSeconds;

  /// Total time in red zone (seconds)
  final double redTimeSeconds;

  /// Session start time
  final DateTime startTime;

  /// Session end time (null if still active)
  final DateTime? endTime;

  /// Debrief notes from user
  final Map<String, String> debriefNotes;

  /// Whether session was completed normally
  final bool isComplete;

  const SessionData({
    required this.id,
    required this.settings,
    required this.calibration,
    this.events = const [],
    this.dataPoints = const [],
    this.greenTimeSeconds = 0,
    this.yellowTimeSeconds = 0,
    this.redTimeSeconds = 0,
    required this.startTime,
    this.endTime,
    this.debriefNotes = const {},
    this.isComplete = false,
  });

  /// Create a new session
  factory SessionData.create({
    required SessionSettings settings,
    required CalibrationData calibration,
  }) {
    return SessionData(
      id: const Uuid().v4(),
      settings: settings,
      calibration: calibration,
      startTime: DateTime.now(),
    );
  }

  /// Get total driving time in seconds
  double get totalTimeSeconds {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inMilliseconds / 1000.0;
  }

  /// Get total active time (in any zone)
  double get activeTimeSeconds =>
      greenTimeSeconds + yellowTimeSeconds + redTimeSeconds;

  /// Get percentage of time in each zone
  double get greenPercent {
    if (activeTimeSeconds == 0) return 100;
    return (greenTimeSeconds / activeTimeSeconds) * 100;
  }

  double get yellowPercent {
    if (activeTimeSeconds == 0) return 0;
    return (yellowTimeSeconds / activeTimeSeconds) * 100;
  }

  double get redPercent {
    if (activeTimeSeconds == 0) return 0;
    return (redTimeSeconds / activeTimeSeconds) * 100;
  }

  /// Get number of events by type
  int get steeringJerkCount =>
      events.where((e) => e.type == DrivingEventType.steeringJerk).length;

  int get brakeJerkCount =>
      events.where((e) => e.type == DrivingEventType.brakeJerk).length;

  int get tractionExceedanceCount =>
      events.where((e) => e.type == DrivingEventType.tractionExceedance).length;

  /// Get maximum speed during session (km/h)
  double get maxSpeedKmh {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((p) => p.speedKmh).reduce((a, b) => a > b ? a : b);
  }

  /// Get average speed during session (km/h)
  double get avgSpeedKmh {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((p) => p.speedKmh).reduce((a, b) => a + b) /
        dataPoints.length;
  }

  /// Copy with new values
  SessionData copyWith({
    String? id,
    SessionSettings? settings,
    CalibrationData? calibration,
    List<DrivingEvent>? events,
    List<DataPoint>? dataPoints,
    double? greenTimeSeconds,
    double? yellowTimeSeconds,
    double? redTimeSeconds,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, String>? debriefNotes,
    bool? isComplete,
  }) {
    return SessionData(
      id: id ?? this.id,
      settings: settings ?? this.settings,
      calibration: calibration ?? this.calibration,
      events: events ?? this.events,
      dataPoints: dataPoints ?? this.dataPoints,
      greenTimeSeconds: greenTimeSeconds ?? this.greenTimeSeconds,
      yellowTimeSeconds: yellowTimeSeconds ?? this.yellowTimeSeconds,
      redTimeSeconds: redTimeSeconds ?? this.redTimeSeconds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      debriefNotes: debriefNotes ?? this.debriefNotes,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'settings': settings.toJson(),
      'calibration': calibration.toJson(),
      'events': events.map((e) => e.toJson()).toList(),
      'dataPoints': dataPoints.map((p) => p.toJson()).toList(),
      'greenTimeSeconds': greenTimeSeconds,
      'yellowTimeSeconds': yellowTimeSeconds,
      'redTimeSeconds': redTimeSeconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'debriefNotes': debriefNotes,
      'isComplete': isComplete,
    };
  }

  /// Create from JSON map
  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      id: json['id'] as String,
      settings: SessionSettings.fromJson(
        json['settings'] as Map<String, dynamic>,
      ),
      calibration: CalibrationData.fromJson(
        json['calibration'] as Map<String, dynamic>,
      ),
      events: (json['events'] as List<dynamic>)
          .map((e) => DrivingEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      dataPoints: (json['dataPoints'] as List<dynamic>)
          .map((p) => DataPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      greenTimeSeconds: (json['greenTimeSeconds'] as num).toDouble(),
      yellowTimeSeconds: (json['yellowTimeSeconds'] as num).toDouble(),
      redTimeSeconds: (json['redTimeSeconds'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      debriefNotes: Map<String, String>.from(
        json['debriefNotes'] as Map<String, dynamic>? ?? {},
      ),
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'SessionData(id: $id, events: ${events.length}, '
        'duration: ${totalTimeSeconds.toStringAsFixed(0)}s)';
  }
}
