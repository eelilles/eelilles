import '../config/constants.dart';
import '../models/driving_event.dart';
import '../models/session_settings.dart';
import '../models/tuning_params.dart';
import 'signal_processor.dart';

/// Result of jerk detection
class JerkDetectionResult {
  /// Whether a steering jerk was detected
  final bool steeringJerkDetected;

  /// Whether a brake/accel jerk was detected
  final bool brakeJerkDetected;

  /// The jerk value that triggered steering detection
  final double? steeringJerkValue;

  /// The jerk value that triggered brake detection
  final double? brakeJerkValue;

  /// Type of jerk event detected (if any)
  final DrivingEventType? eventType;

  const JerkDetectionResult({
    this.steeringJerkDetected = false,
    this.brakeJerkDetected = false,
    this.steeringJerkValue,
    this.brakeJerkValue,
    this.eventType,
  });

  bool get anyJerkDetected => steeringJerkDetected || brakeJerkDetected;
}

/// Detects jerky steering and braking inputs
class JerkDetector {
  // Cooldown tracking
  DateTime? _lastSteeringJerk;
  DateTime? _lastBrakeJerk;

  // Configuration
  TuningParams _params = TuningParams.defaults();

  void updateParams(TuningParams params) {
    _params = params;
  }

  /// Check for jerk events
  JerkDetectionResult detect(
    ProcessedSensorData data,
    SessionSettings settings,
  ) {
    final now = DateTime.now();

    // Get road-adjusted thresholds
    final roadMultiplier = settings.roadSensitivity;

    final yawThresh = _params.jerkYawThreshold * roadMultiplier;
    final latThresh = _params.jerkLatThreshold * roadMultiplier;
    final longThresh = _params.jerkLongThreshold * roadMultiplier;
    final deltaYawThresh = _params.deltaYawRateThreshold * roadMultiplier;

    bool steeringJerk = false;
    bool brakeJerk = false;
    double? steeringJerkValue;
    double? brakeJerkValue;

    // Check steering jerk (requires minimum speed)
    if (data.speedKmh > _params.jerkSteeringMinSpeedKmh) {
      // Check cooldown
      final canTrigger = _lastSteeringJerk == null ||
          now.difference(_lastSteeringJerk!).inSeconds >=
              JERK_EVENT_COOLDOWN_S;

      if (canTrigger) {
        // Check any of the steering jerk conditions
        if (data.yawJerk.abs() > yawThresh) {
          steeringJerk = true;
          steeringJerkValue = data.yawJerk;
        } else if (data.latJerk.abs() > latThresh) {
          steeringJerk = true;
          steeringJerkValue = data.latJerk;
        } else if (data.deltaYawRate.abs() > deltaYawThresh) {
          steeringJerk = true;
          steeringJerkValue = data.deltaYawRate;
        }

        if (steeringJerk) {
          _lastSteeringJerk = now;
        }
      }
    }

    // Check brake jerk (requires minimum speed)
    if (data.speedKmh > _params.jerkBrakeMinSpeedKmh) {
      // Check cooldown
      final canTrigger = _lastBrakeJerk == null ||
          now.difference(_lastBrakeJerk!).inSeconds >= JERK_EVENT_COOLDOWN_S;

      if (canTrigger && data.longJerk.abs() > longThresh) {
        brakeJerk = true;
        brakeJerkValue = data.longJerk;
        _lastBrakeJerk = now;
      }
    }

    // Determine event type
    DrivingEventType? eventType;
    if (steeringJerk) {
      eventType = DrivingEventType.steeringJerk;
    } else if (brakeJerk) {
      eventType = DrivingEventType.brakeJerk;
    }

    return JerkDetectionResult(
      steeringJerkDetected: steeringJerk,
      brakeJerkDetected: brakeJerk,
      steeringJerkValue: steeringJerkValue,
      brakeJerkValue: brakeJerkValue,
      eventType: eventType,
    );
  }

  /// Reset detector state
  void reset() {
    _lastSteeringJerk = null;
    _lastBrakeJerk = null;
  }
}
