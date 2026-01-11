import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/constants.dart';
import '../models/models.dart';

/// Manages the active driving session state
class SessionProvider extends ChangeNotifier {
  /// Current active session (null if no session)
  SessionData? _activeSession;
  SessionData? get activeSession => _activeSession;

  /// Whether a session is currently active
  bool get hasActiveSession => _activeSession != null;

  // ============ Live Sensor Data ============

  /// Current speed in km/h
  double _speedKmh = 0;
  double get speedKmh => _speedKmh;

  /// Current longitudinal acceleration (m/s²) - forward/brake
  double _aLong = 0;
  double get aLong => _aLong;

  /// Current lateral acceleration (m/s²) - left/right
  double _aLat = 0;
  double get aLat => _aLat;

  /// Current yaw rate (rad/s)
  double _yawRate = 0;
  double get yawRate => _yawRate;

  /// Current estimated grade (%)
  double _estimatedGrade = 0;
  double get estimatedGrade => _estimatedGrade;

  /// Whether grade estimation is in steady state
  bool _gradeInSteadyState = false;
  bool get gradeInSteadyState => _gradeInSteadyState;

  // ============ Traction Fractions ============

  /// Longitudinal fraction (0-1+)
  double _longFrac = 0;
  double get longFrac => _longFrac;

  /// Lateral fraction (0-1+)
  double _latFrac = 0;
  double get latFrac => _latFrac;

  /// Combined traction fraction
  double _combinedFrac = 0;
  double get combinedFrac => _combinedFrac;

  // ============ Motion Lock State ============

  /// Whether controls are locked due to motion
  bool _isMoving = false;
  bool get isMoving => _isMoving;

  /// Time since speed dropped below unlock threshold
  DateTime? _lowSpeedSince;

  // ============ Smoothness State ============

  /// Whether driving is currently "choppy"
  bool _isChoppy = false;
  bool get isChoppy => _isChoppy;

  /// Timer to reset choppy state
  Timer? _choppyResetTimer;

  // ============ Zone Tracking ============

  double _greenTimeSeconds = 0;
  double _yellowTimeSeconds = 0;
  double _redTimeSeconds = 0;

  DateTime? _lastZoneUpdate;
  String _currentZone = 'green';

  // ============ Event Tracking ============

  List<DrivingEvent> _events = [];
  List<DrivingEvent> get events => List.unmodifiable(_events);

  DateTime? _lastSteeringJerkTime;
  DateTime? _lastBrakeJerkTime;
  DateTime? _tractionExceedanceStartTime;

  // ============ Data Logging ============

  List<DataPoint> _dataPoints = [];
  DateTime? _lastDataPointTime;

  // ============ Session Lifecycle ============

  /// Start a new driving session
  void startSession({
    required SessionSettings settings,
    required CalibrationData calibration,
  }) {
    _activeSession = SessionData.create(
      settings: settings,
      calibration: calibration,
    );
    _resetSessionState();
    notifyListeners();
  }

  /// End the current session
  SessionData? endSession() {
    if (_activeSession == null) return null;

    final completedSession = _activeSession!.copyWith(
      endTime: DateTime.now(),
      events: List.from(_events),
      dataPoints: List.from(_dataPoints),
      greenTimeSeconds: _greenTimeSeconds,
      yellowTimeSeconds: _yellowTimeSeconds,
      redTimeSeconds: _redTimeSeconds,
      isComplete: true,
    );

    _activeSession = null;
    _resetSessionState();
    notifyListeners();

    return completedSession;
  }

  void _resetSessionState() {
    _speedKmh = 0;
    _aLong = 0;
    _aLat = 0;
    _yawRate = 0;
    _estimatedGrade = 0;
    _gradeInSteadyState = false;
    _longFrac = 0;
    _latFrac = 0;
    _combinedFrac = 0;
    _isMoving = false;
    _lowSpeedSince = null;
    _isChoppy = false;
    _choppyResetTimer?.cancel();
    _choppyResetTimer = null;
    _greenTimeSeconds = 0;
    _yellowTimeSeconds = 0;
    _redTimeSeconds = 0;
    _lastZoneUpdate = null;
    _currentZone = 'green';
    _events = [];
    _lastSteeringJerkTime = null;
    _lastBrakeJerkTime = null;
    _tractionExceedanceStartTime = null;
    _dataPoints = [];
    _lastDataPointTime = null;
  }

  // ============ Live Updates ============

  /// Update sensor values (called from sensor service)
  void updateSensorData({
    required double speedKmh,
    required double aLong,
    required double aLat,
    required double yawRate,
    double? estimatedGrade,
    bool? gradeInSteadyState,
  }) {
    _speedKmh = speedKmh;
    _aLong = aLong;
    _aLat = aLat;
    _yawRate = yawRate;

    if (estimatedGrade != null) {
      _estimatedGrade = estimatedGrade;
    }
    if (gradeInSteadyState != null) {
      _gradeInSteadyState = gradeInSteadyState;
    }

    _updateMotionLockState();
    notifyListeners();
  }

  /// Update traction fractions (called from traction calculator)
  void updateTractionFractions({
    required double longFrac,
    required double latFrac,
    required double combinedFrac,
  }) {
    _longFrac = longFrac;
    _latFrac = latFrac;
    _combinedFrac = combinedFrac;

    if (hasActiveSession) {
      _updateZoneTracking();
      _checkTractionExceedance();
      _logDataPoint();
    }

    notifyListeners();
  }

  void _updateMotionLockState() {
    final now = DateTime.now();

    if (_speedKmh > MOTION_LOCK_SPEED_KMH) {
      _isMoving = true;
      _lowSpeedSince = null;
    } else if (_speedKmh < MOTION_UNLOCK_SPEED_KMH) {
      _lowSpeedSince ??= now;

      final duration = now.difference(_lowSpeedSince!).inMilliseconds / 1000.0;
      if (duration >= MOTION_UNLOCK_DURATION_S) {
        _isMoving = false;
      }
    } else {
      // Between unlock and lock thresholds - maintain current state
      _lowSpeedSince = null;
    }
  }

  void _updateZoneTracking() {
    final now = DateTime.now();
    if (_lastZoneUpdate != null) {
      final deltaSeconds =
          now.difference(_lastZoneUpdate!).inMilliseconds / 1000.0;

      switch (_currentZone) {
        case 'green':
          _greenTimeSeconds += deltaSeconds;
          break;
        case 'yellow':
          _yellowTimeSeconds += deltaSeconds;
          break;
        case 'red':
          _redTimeSeconds += deltaSeconds;
          break;
      }
    }

    _currentZone = DataPoint.getColorZone(_combinedFrac);
    _lastZoneUpdate = now;
  }

  void _checkTractionExceedance() {
    if (_combinedFrac > 1.0) {
      _tractionExceedanceStartTime ??= DateTime.now();

      final duration = DateTime.now()
              .difference(_tractionExceedanceStartTime!)
              .inMilliseconds /
          1000.0;

      if (duration >= TRACTION_EXCEEDANCE_DURATION) {
        _recordEvent(DrivingEventType.tractionExceedance);
        _tractionExceedanceStartTime = null;
      }
    } else {
      _tractionExceedanceStartTime = null;
    }
  }

  void _logDataPoint() {
    final now = DateTime.now();
    final intervalMs = 1000 ~/ SESSION_LOG_RATE_HZ;

    if (_lastDataPointTime == null ||
        now.difference(_lastDataPointTime!).inMilliseconds >= intervalMs) {
      _dataPoints.add(DataPoint(
        timestamp: now,
        speedKmh: _speedKmh,
        combinedFrac: _combinedFrac,
        longFrac: _longFrac,
        latFrac: _latFrac,
        gradePercent: _estimatedGrade,
        colorZone: _currentZone,
      ));
      _lastDataPointTime = now;
    }
  }

  // ============ Event Recording ============

  /// Record a jerk event (called from jerk detector)
  void recordJerkEvent(DrivingEventType type, {double? jerkValue}) {
    final now = DateTime.now();

    // Check cooldown
    if (type == DrivingEventType.steeringJerk) {
      if (_lastSteeringJerkTime != null &&
          now.difference(_lastSteeringJerkTime!).inSeconds <
              JERK_EVENT_COOLDOWN_S) {
        return;
      }
      _lastSteeringJerkTime = now;
    } else if (type == DrivingEventType.brakeJerk) {
      if (_lastBrakeJerkTime != null &&
          now.difference(_lastBrakeJerkTime!).inSeconds <
              JERK_EVENT_COOLDOWN_S) {
        return;
      }
      _lastBrakeJerkTime = now;
    }

    _recordEvent(type, jerkValue: jerkValue);
    _setChoppy();
  }

  void _recordEvent(DrivingEventType type, {double? jerkValue}) {
    if (!hasActiveSession) return;

    final event = DrivingEvent(
      type: type,
      timestamp: DateTime.now(),
      speedKmh: _speedKmh,
      aLong: _aLong,
      aLat: _aLat,
      gradePercent: _estimatedGrade,
      combinedFrac: _combinedFrac,
      jerkValue: jerkValue,
      roadCondition: _activeSession!.settings.roadCondition,
      driverLevel: _activeSession!.settings.driverLevel,
    );

    _events.add(event);
    notifyListeners();
  }

  void _setChoppy() {
    _isChoppy = true;
    _choppyResetTimer?.cancel();
    _choppyResetTimer = Timer(
      Duration(seconds: CHOPPY_DISPLAY_DURATION_S.toInt()),
      () {
        _isChoppy = false;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  // ============ Debrief ============

  /// Save debrief notes
  void saveDebriefNotes(Map<String, String> notes) {
    if (_activeSession != null) {
      _activeSession = _activeSession!.copyWith(debriefNotes: notes);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _choppyResetTimer?.cancel();
    super.dispose();
  }
}
