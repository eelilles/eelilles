import 'dart:math' as math;

import '../config/constants.dart';
import 'sensor_service.dart';
import 'signal_processor.dart';

/// Grade estimation state
class GradeEstimate {
  /// Current estimated grade (%)
  final double gradePercent;

  /// Whether we're in steady state (actively updating)
  final bool inSteadyState;

  /// How long we've been in steady state (seconds)
  final double steadyStateDuration;

  /// Instantaneous grade reading before smoothing
  final double instantGrade;

  const GradeEstimate({
    required this.gradePercent,
    required this.inSteadyState,
    required this.steadyStateDuration,
    required this.instantGrade,
  });

  factory GradeEstimate.zero() {
    return const GradeEstimate(
      gradePercent: 0,
      inSteadyState: false,
      steadyStateDuration: 0,
      instantGrade: 0,
    );
  }
}

/// Estimates road grade from gravity vector during steady-state driving
class GradeEstimator {
  // Smoothed grade value
  double _smoothedGrade = 0;
  DateTime? _lastUpdate;

  // Steady state tracking
  bool _inSteadyState = false;
  DateTime? _steadyStateStart;

  // Configuration
  double _tau;
  double _maxRate;
  double _minSpeed;
  double _maxAccel;
  double _requiredDuration;

  GradeEstimator({
    double tau = GRADE_TAU_S,
    double maxRate = GRADE_MAX_RATE,
    double minSpeed = STEADY_STATE_SPEED_MIN_KMH,
    double maxAccel = STEADY_STATE_ACCEL_MAX_G,
    double requiredDuration = STEADY_STATE_DURATION_S,
  })  : _tau = tau,
        _maxRate = maxRate,
        _minSpeed = minSpeed,
        _maxAccel = maxAccel,
        _requiredDuration = requiredDuration;

  /// Update grade estimate with new sensor data
  GradeEstimate update(
    VehicleSensorData vehicle,
    ProcessedSensorData processed,
  ) {
    final now = DateTime.now();

    // Check steady state conditions
    final speedOk = processed.speedKmh >= _minSpeed;
    final accelOk =
        (processed.displayALong.abs() / G) < _maxAccel &&
        (processed.displayALat.abs() / G) < _maxAccel;

    final wasInSteadyState = _inSteadyState;

    if (speedOk && accelOk) {
      if (!_inSteadyState) {
        _steadyStateStart = now;
        _inSteadyState = false; // Not yet, need duration
      } else {
        // Check if we've been stable long enough
        final duration =
            now.difference(_steadyStateStart!).inMilliseconds / 1000.0;
        if (duration >= _requiredDuration) {
          _inSteadyState = true;
        }
      }
    } else {
      _inSteadyState = false;
      _steadyStateStart = null;
    }

    // Calculate instantaneous grade from gravity component
    // In vehicle frame, when going uphill:
    // - Gravity has a forward (+X) component
    // - Grade angle theta = atan2(g_x, -g_z)
    // Note: We need the raw gravity, not the compensated accelerations

    // For this, we need to estimate gravity from the vertical acceleration
    // when we know we're in steady state (no dynamic accelerations)

    // Simplified: use the measured aLong as an indicator
    // On a grade, stationary car sees a_long = -g * sin(theta)
    // So grade = -asin(a_long / g) when stationary

    // During driving, we use the filtered values and assume
    // any persistent offset in aLong is due to grade

    double instantGrade = 0;
    if (_inSteadyState) {
      // Use the event-path aLong as proxy for grade
      // In steady state, persistent aLong offset = grade component
      final gradeComponent = processed.eventALong / G;
      instantGrade = math.atan(gradeComponent) * 180 / math.pi * 100 / 90;
      instantGrade = instantGrade.clamp(GRADE_MIN_PERCENT, GRADE_MAX_PERCENT);
    }

    // Update smoothed grade (only when in steady state)
    double steadyStateDuration = 0;
    if (_inSteadyState && _steadyStateStart != null) {
      steadyStateDuration =
          now.difference(_steadyStateStart!).inMilliseconds / 1000.0;

      if (_lastUpdate != null) {
        final dt = now.difference(_lastUpdate!).inMicroseconds / 1e6;
        if (dt > 0) {
          // Apply EMA smoothing
          final alpha = 1 - math.exp(-dt / _tau);
          var newGrade = alpha * instantGrade + (1 - alpha) * _smoothedGrade;

          // Rate limit
          final maxChange = _maxRate * dt;
          final change = newGrade - _smoothedGrade;
          if (change.abs() > maxChange) {
            newGrade = _smoothedGrade + maxChange * change.sign;
          }

          _smoothedGrade = newGrade.clamp(GRADE_MIN_PERCENT, GRADE_MAX_PERCENT);
        }
      }
    }

    _lastUpdate = now;

    return GradeEstimate(
      gradePercent: _smoothedGrade,
      inSteadyState: _inSteadyState,
      steadyStateDuration: steadyStateDuration,
      instantGrade: instantGrade,
    );
  }

  /// Reset estimator
  void reset() {
    _smoothedGrade = 0;
    _lastUpdate = null;
    _inSteadyState = false;
    _steadyStateStart = null;
  }

  /// Set initial grade (from manual setting)
  void setInitialGrade(double gradePercent) {
    _smoothedGrade = gradePercent.clamp(GRADE_MIN_PERCENT, GRADE_MAX_PERCENT);
  }

  /// Update configuration
  void updateConfig({
    double? tau,
    double? maxRate,
    double? minSpeed,
    double? maxAccel,
    double? requiredDuration,
  }) {
    if (tau != null) _tau = tau;
    if (maxRate != null) _maxRate = maxRate;
    if (minSpeed != null) _minSpeed = minSpeed;
    if (maxAccel != null) _maxAccel = maxAccel;
    if (requiredDuration != null) _requiredDuration = requiredDuration;
  }
}
