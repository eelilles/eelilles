import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart';

import '../config/constants.dart';
import '../models/calibration_data.dart';

/// Status of calibration process
enum CalibrationStatus {
  idle,
  capturing,
  processing,
  success,
  failed,
}

/// Result of calibration attempt
class CalibrationResult {
  final CalibrationStatus status;
  final CalibrationData? data;
  final String? errorMessage;
  final double progress; // 0.0 to 1.0

  const CalibrationResult({
    required this.status,
    this.data,
    this.errorMessage,
    this.progress = 0.0,
  });
}

/// Service for calibrating phone orientation to vehicle frame
class CalibrationService {
  StreamSubscription<AccelerometerEvent>? _subscription;

  final List<Vector3> _samples = [];
  DateTime? _captureStartTime;

  CalibrationStatus _status = CalibrationStatus.idle;
  CalibrationStatus get status => _status;

  /// Stream of calibration progress
  final _progressController = StreamController<CalibrationResult>.broadcast();
  Stream<CalibrationResult> get progressStream => _progressController.stream;

  /// Start calibration capture
  /// Returns a Future that completes with the calibration result
  Future<CalibrationResult> startCalibration() async {
    if (_status == CalibrationStatus.capturing) {
      return CalibrationResult(
        status: CalibrationStatus.failed,
        errorMessage: 'Calibration already in progress',
      );
    }

    _samples.clear();
    _status = CalibrationStatus.capturing;
    _captureStartTime = DateTime.now();

    _emitProgress(0.0);

    // Start capturing accelerometer data
    final completer = Completer<CalibrationResult>();

    _subscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 20), // 50 Hz
    ).listen((event) {
      _samples.add(Vector3(event.x, event.y, event.z));

      final elapsed =
          DateTime.now().difference(_captureStartTime!).inMilliseconds /
              1000.0;
      final progress = (elapsed / CALIBRATION_DURATION_S).clamp(0.0, 1.0);

      _emitProgress(progress);

      if (elapsed >= CALIBRATION_DURATION_S) {
        _subscription?.cancel();
        _processCalibration(completer);
      }
    }, onError: (e) {
      _subscription?.cancel();
      _status = CalibrationStatus.failed;
      final result = CalibrationResult(
        status: CalibrationStatus.failed,
        errorMessage: 'Sensor error: $e',
      );
      _progressController.add(result);
      completer.complete(result);
    });

    return completer.future;
  }

  void _emitProgress(double progress) {
    _progressController.add(CalibrationResult(
      status: CalibrationStatus.capturing,
      progress: progress,
    ));
  }

  void _processCalibration(Completer<CalibrationResult> completer) {
    _status = CalibrationStatus.processing;
    _progressController.add(const CalibrationResult(
      status: CalibrationStatus.processing,
      progress: 1.0,
    ));

    try {
      // Calculate average gravity vector
      if (_samples.length < 50) {
        throw Exception('Not enough samples collected');
      }

      Vector3 avgGravity = Vector3.zero();
      for (final sample in _samples) {
        avgGravity += sample;
      }
      avgGravity /= _samples.length.toDouble();

      // Calculate variance to ensure phone was stationary
      double variance = 0;
      for (final sample in _samples) {
        final diff = sample - avgGravity;
        variance += diff.length2;
      }
      variance /= _samples.length;
      variance = math.sqrt(variance);

      if (variance > CALIBRATION_VARIANCE_MAX) {
        throw Exception(
          'Phone was not stationary. Keep phone still during calibration.',
        );
      }

      // Check gravity magnitude
      final gravityMag = avgGravity.length;
      if ((gravityMag - EXPECTED_GRAVITY).abs() > 1.0) {
        throw Exception(
          'Invalid gravity reading (${gravityMag.toStringAsFixed(2)} m/s²). '
          'Ensure phone sensors are working correctly.',
        );
      }

      // Build rotation matrix from phone frame to vehicle frame
      // Vehicle frame: +X forward, +Y right, +Z up
      // We know gravity points down, so avgGravity should become -Z in vehicle frame

      final transform = _buildTransformMatrix(avgGravity);

      final calibrationData = CalibrationData(
        transformMatrix: transform,
        timestamp: DateTime.now(),
        isValid: true,
        gravityMagnitude: gravityMag,
        measurementVariance: variance,
        rawGravity: avgGravity,
      );

      _status = CalibrationStatus.success;
      final result = CalibrationResult(
        status: CalibrationStatus.success,
        data: calibrationData,
        progress: 1.0,
      );
      _progressController.add(result);
      completer.complete(result);
    } catch (e) {
      _status = CalibrationStatus.failed;
      final result = CalibrationResult(
        status: CalibrationStatus.failed,
        errorMessage: e.toString(),
        progress: 1.0,
      );
      _progressController.add(result);
      completer.complete(result);
    }
  }

  /// Build rotation matrix to transform from phone frame to vehicle frame
  /// Assumes phone is mounted with screen facing driver (can be any orientation)
  /// Uses gravity to determine down direction
  Matrix3 _buildTransformMatrix(Vector3 gravity) {
    // Normalize gravity vector (points down in phone frame)
    final down = gravity.normalized();

    // We need to determine forward direction
    // For MVP, assume the phone's -Y axis points forward when mounted
    // This is typical for dashboard/windshield mounts with phone upright

    // Vehicle frame: X=forward, Y=right, Z=up
    // Phone typical: X=right, Y=up, Z=out of screen

    // Start with assumption: phone -Y is forward, -Z is up
    // But we measure gravity to find actual down direction

    // Create orthonormal basis with gravity as -Z
    final vehicleDown = down; // This becomes -Z in vehicle frame

    // Assume phone's -Y (or closest perpendicular to gravity) is forward
    Vector3 phoneUp = Vector3(0, -1, 0); // Assuming -Y is forward

    // Make sure forward is perpendicular to down
    Vector3 forward = phoneUp - vehicleDown * phoneUp.dot(vehicleDown);
    if (forward.length < 0.1) {
      // Phone is nearly horizontal, use -Z as forward guess
      forward = Vector3(0, 0, -1) -
          vehicleDown * Vector3(0, 0, -1).dot(vehicleDown);
    }
    forward.normalize();

    // Right = forward × up (cross product)
    final right = forward.cross(-vehicleDown);
    right.normalize();

    // Recalculate forward to ensure orthogonality
    forward = (-vehicleDown).cross(right);
    forward.normalize();

    // Build rotation matrix
    // Columns are the phone-frame basis vectors expressed in vehicle frame
    // Row i, Col j = component of phone axis j along vehicle axis i
    final matrix = Matrix3(
      forward.x, right.x, -vehicleDown.x, // X (forward) components
      forward.y, right.y, -vehicleDown.y, // Y (right) components
      forward.z, right.z, -vehicleDown.z, // Z (up) components
    );

    return matrix;
  }

  /// Cancel ongoing calibration
  void cancel() {
    _subscription?.cancel();
    _subscription = null;
    _samples.clear();
    _status = CalibrationStatus.idle;
  }

  void dispose() {
    cancel();
    _progressController.close();
  }
}
