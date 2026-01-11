import 'dart:collection';
import 'dart:math' as math;

import '../config/constants.dart';
import 'sensor_service.dart';

/// Processed sensor data with display and event paths
class ProcessedSensorData {
  // Display path (heavy smoothing for UI)
  final double displayALong;
  final double displayALat;
  final double displayYawRate;

  // Event path (light smoothing for detection)
  final double eventALong;
  final double eventALat;
  final double eventYawRate;

  // Jerk values (derivatives of event path)
  final double longJerk;
  final double latJerk;
  final double yawJerk;

  // Delta yaw rate (200ms window)
  final double deltaYawRate;

  // Speed
  final double speedKmh;
  final double speedMps;

  // Timestamp
  final DateTime timestamp;

  const ProcessedSensorData({
    required this.displayALong,
    required this.displayALat,
    required this.displayYawRate,
    required this.eventALong,
    required this.eventALat,
    required this.eventYawRate,
    required this.longJerk,
    required this.latJerk,
    required this.yawJerk,
    required this.deltaYawRate,
    required this.speedKmh,
    required this.speedMps,
    required this.timestamp,
  });

  factory ProcessedSensorData.zero() {
    return ProcessedSensorData(
      displayALong: 0,
      displayALat: 0,
      displayYawRate: 0,
      eventALong: 0,
      eventALat: 0,
      eventYawRate: 0,
      longJerk: 0,
      latJerk: 0,
      yawJerk: 0,
      deltaYawRate: 0,
      speedKmh: 0,
      speedMps: 0,
      timestamp: DateTime.now(),
    );
  }
}

/// Exponential Moving Average filter
class EmaFilter {
  final double tau; // Time constant in seconds
  double _value = 0;
  DateTime? _lastUpdate;
  bool _initialized = false;

  EmaFilter({required this.tau});

  double update(double input, DateTime timestamp) {
    if (!_initialized || _lastUpdate == null) {
      _value = input;
      _lastUpdate = timestamp;
      _initialized = true;
      return _value;
    }

    final dt = timestamp.difference(_lastUpdate!).inMicroseconds / 1e6;
    if (dt <= 0) return _value;

    // EMA: alpha = 1 - exp(-dt/tau)
    final alpha = 1 - math.exp(-dt / tau);
    _value = alpha * input + (1 - alpha) * _value;
    _lastUpdate = timestamp;

    return _value;
  }

  double get value => _value;

  void reset() {
    _value = 0;
    _lastUpdate = null;
    _initialized = false;
  }
}

/// Derivative calculator with smoothing
class DerivativeFilter {
  double _prevValue = 0;
  DateTime? _prevTimestamp;
  final EmaFilter _smoother;
  bool _initialized = false;

  DerivativeFilter({double smoothingTau = 0.05})
      : _smoother = EmaFilter(tau: smoothingTau);

  double update(double input, DateTime timestamp) {
    if (!_initialized || _prevTimestamp == null) {
      _prevValue = input;
      _prevTimestamp = timestamp;
      _initialized = true;
      return 0;
    }

    final dt = timestamp.difference(_prevTimestamp!).inMicroseconds / 1e6;
    if (dt <= 0) return _smoother.value;

    final derivative = (input - _prevValue) / dt;
    _prevValue = input;
    _prevTimestamp = timestamp;

    return _smoother.update(derivative, timestamp);
  }

  double get value => _smoother.value;

  void reset() {
    _prevValue = 0;
    _prevTimestamp = null;
    _initialized = false;
    _smoother.reset();
  }
}

/// Windowed history buffer for delta calculations
class WindowBuffer {
  final Duration windowDuration;
  final Queue<(DateTime, double)> _buffer = Queue();

  WindowBuffer({required this.windowDuration});

  void add(DateTime timestamp, double value) {
    _buffer.addLast((timestamp, value));

    // Remove old entries
    while (_buffer.isNotEmpty) {
      final oldest = _buffer.first;
      if (timestamp.difference(oldest.$1) > windowDuration) {
        _buffer.removeFirst();
      } else {
        break;
      }
    }
  }

  /// Get the value from approximately windowDuration ago
  double? getOldValue() {
    if (_buffer.isEmpty) return null;
    return _buffer.first.$2;
  }

  /// Get the delta between current and old value
  double getDelta(double currentValue) {
    final oldValue = getOldValue();
    if (oldValue == null) return 0;
    return currentValue - oldValue;
  }

  void reset() {
    _buffer.clear();
  }
}

/// Signal processor with display and event paths
class SignalProcessor {
  // Display path filters (heavy smoothing)
  late EmaFilter _displayALongFilter;
  late EmaFilter _displayALatFilter;
  late EmaFilter _displayYawRateFilter;

  // Event path filters (light smoothing)
  late EmaFilter _eventALongFilter;
  late EmaFilter _eventALatFilter;
  late EmaFilter _eventYawRateFilter;

  // Derivative filters for jerk detection
  late DerivativeFilter _longJerkFilter;
  late DerivativeFilter _latJerkFilter;
  late DerivativeFilter _yawJerkFilter;

  // Window buffer for delta yaw rate
  late WindowBuffer _yawRateBuffer;

  // Configurable time constants
  double _displayTau;
  double _eventTau;

  SignalProcessor({
    double displayTau = DISPLAY_TAU_S,
    double eventTau = EVENT_TAU_S,
  })  : _displayTau = displayTau,
        _eventTau = eventTau {
    _initFilters();
  }

  void _initFilters() {
    _displayALongFilter = EmaFilter(tau: _displayTau);
    _displayALatFilter = EmaFilter(tau: _displayTau);
    _displayYawRateFilter = EmaFilter(tau: _displayTau);

    _eventALongFilter = EmaFilter(tau: _eventTau);
    _eventALatFilter = EmaFilter(tau: _eventTau);
    _eventYawRateFilter = EmaFilter(tau: _eventTau);

    _longJerkFilter = DerivativeFilter(smoothingTau: _eventTau);
    _latJerkFilter = DerivativeFilter(smoothingTau: _eventTau);
    _yawJerkFilter = DerivativeFilter(smoothingTau: _eventTau);

    _yawRateBuffer = WindowBuffer(
      windowDuration: const Duration(milliseconds: 200),
    );
  }

  /// Update filter time constants
  void updateTau({double? displayTau, double? eventTau}) {
    if (displayTau != null) _displayTau = displayTau;
    if (eventTau != null) _eventTau = eventTau;
    reset();
  }

  /// Process raw vehicle sensor data
  ProcessedSensorData process(VehicleSensorData input) {
    final ts = input.timestamp;

    // Display path
    final displayALong = _displayALongFilter.update(input.aLong, ts);
    final displayALat = _displayALatFilter.update(input.aLat, ts);
    final displayYawRate = _displayYawRateFilter.update(input.yawRate, ts);

    // Event path
    final eventALong = _eventALongFilter.update(input.aLong, ts);
    final eventALat = _eventALatFilter.update(input.aLat, ts);
    final eventYawRate = _eventYawRateFilter.update(input.yawRate, ts);

    // Jerk (derivatives of event path)
    final longJerk = _longJerkFilter.update(eventALong, ts);
    final latJerk = _latJerkFilter.update(eventALat, ts);
    final yawJerk = _yawJerkFilter.update(eventYawRate, ts);

    // Delta yaw rate
    _yawRateBuffer.add(ts, eventYawRate);
    final deltaYawRate = _yawRateBuffer.getDelta(eventYawRate);

    return ProcessedSensorData(
      displayALong: displayALong,
      displayALat: displayALat,
      displayYawRate: displayYawRate,
      eventALong: eventALong,
      eventALat: eventALat,
      eventYawRate: eventYawRate,
      longJerk: longJerk,
      latJerk: latJerk,
      yawJerk: yawJerk,
      deltaYawRate: deltaYawRate,
      speedKmh: input.speedKmh,
      speedMps: input.speedMps,
      timestamp: ts,
    );
  }

  /// Reset all filters
  void reset() {
    _initFilters();
  }
}
