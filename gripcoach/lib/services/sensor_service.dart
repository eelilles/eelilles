import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart';

import '../config/constants.dart';
import '../models/calibration_data.dart';

/// Raw sensor data from device
class RawSensorData {
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double speedMps;
  final DateTime timestamp;

  const RawSensorData({
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.speedMps,
    required this.timestamp,
  });

  /// Get speed in km/h
  double get speedKmh => speedMps * 3.6;

  /// Get acceleration vector (phone frame)
  Vector3 get accelVector => Vector3(accelX, accelY, accelZ);

  /// Get gyro vector (phone frame)
  Vector3 get gyroVector => Vector3(gyroX, gyroY, gyroZ);
}

/// Vehicle-frame sensor data after calibration transform
class VehicleSensorData {
  /// Longitudinal acceleration (m/s²) - forward (+) / braking (-)
  final double aLong;

  /// Lateral acceleration (m/s²) - right (+) / left (-)
  final double aLat;

  /// Vertical acceleration (m/s²) - up (+) / down (-)
  final double aVert;

  /// Yaw rate (rad/s) - clockwise (+) when viewed from above
  final double yawRate;

  /// Pitch rate (rad/s)
  final double pitchRate;

  /// Roll rate (rad/s)
  final double rollRate;

  /// Speed (km/h)
  final double speedKmh;

  /// Speed (m/s)
  final double speedMps;

  /// Timestamp
  final DateTime timestamp;

  const VehicleSensorData({
    required this.aLong,
    required this.aLat,
    required this.aVert,
    required this.yawRate,
    required this.pitchRate,
    required this.rollRate,
    required this.speedKmh,
    required this.speedMps,
    required this.timestamp,
  });

  /// Create zero data
  factory VehicleSensorData.zero() {
    return VehicleSensorData(
      aLong: 0,
      aLat: 0,
      aVert: 0,
      yawRate: 0,
      pitchRate: 0,
      rollRate: 0,
      speedKmh: 0,
      speedMps: 0,
      timestamp: DateTime.now(),
    );
  }
}

/// Service for managing device sensors (accelerometer, gyroscope, GPS)
class SensorService extends ChangeNotifier {
  // Subscriptions
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  StreamSubscription<Position>? _positionSubscription;

  // Latest raw values
  double _accelX = 0;
  double _accelY = 0;
  double _accelZ = 0;
  double _gyroX = 0;
  double _gyroY = 0;
  double _gyroZ = 0;
  double _speedMps = 0;

  // Calibration transform
  CalibrationData? _calibration;

  // Stream controller for processed data
  final _dataController = StreamController<VehicleSensorData>.broadcast();
  Stream<VehicleSensorData> get dataStream => _dataController.stream;

  // Timer for consistent data rate
  Timer? _dataTimer;

  /// Whether sensors are currently active
  bool _isActive = false;
  bool get isActive => _isActive;

  /// Last error message
  String? _lastError;
  String? get lastError => _lastError;

  /// Start sensor data collection
  Future<void> start({CalibrationData? calibration}) async {
    if (_isActive) return;

    _calibration = calibration;
    _lastError = null;

    try {
      // Start accelerometer
      _accelSubscription = accelerometerEventStream(
        samplingPeriod: Duration(microseconds: 1000000 ~/ SENSOR_RATE_HZ),
      ).listen((event) {
        _accelX = event.x;
        _accelY = event.y;
        _accelZ = event.z;
      }, onError: (e) {
        _lastError = 'Accelerometer error: $e';
      });

      // Start gyroscope
      _gyroSubscription = gyroscopeEventStream(
        samplingPeriod: Duration(microseconds: 1000000 ~/ SENSOR_RATE_HZ),
      ).listen((event) {
        _gyroX = event.x;
        _gyroY = event.y;
        _gyroZ = event.z;
      }, onError: (e) {
        _lastError = 'Gyroscope error: $e';
      });

      // Start GPS for speed
      await _startGps();

      // Start data timer for consistent output rate
      _dataTimer = Timer.periodic(
        Duration(milliseconds: 1000 ~/ SENSOR_RATE_HZ),
        (_) => _emitData(),
      );

      _isActive = true;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to start sensors: $e';
      await stop();
      rethrow;
    }
  }

  Future<void> _startGps() async {
    // Check permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Start position stream
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen((position) {
      _speedMps = position.speed >= 0 ? position.speed : 0;
    }, onError: (e) {
      // GPS errors are non-fatal, use 0 speed
      _speedMps = 0;
    });
  }

  void _emitData() {
    if (!_isActive) return;

    final raw = RawSensorData(
      accelX: _accelX,
      accelY: _accelY,
      accelZ: _accelZ,
      gyroX: _gyroX,
      gyroY: _gyroY,
      gyroZ: _gyroZ,
      speedMps: _speedMps,
      timestamp: DateTime.now(),
    );

    final vehicle = _transformToVehicleFrame(raw);
    _dataController.add(vehicle);
  }

  VehicleSensorData _transformToVehicleFrame(RawSensorData raw) {
    if (_calibration == null || !_calibration!.isValid) {
      // No calibration - assume phone is flat with top pointing forward
      return VehicleSensorData(
        aLong: -raw.accelY,  // Phone Y- is forward
        aLat: raw.accelX,    // Phone X+ is right
        aVert: -raw.accelZ,  // Phone Z- is up (gravity is down)
        yawRate: -raw.gyroZ,
        pitchRate: raw.gyroX,
        rollRate: raw.gyroY,
        speedKmh: raw.speedKmh,
        speedMps: raw.speedMps,
        timestamp: raw.timestamp,
      );
    }

    // Apply calibration transform
    final accelVehicle = _calibration!.transformToVehicle(raw.accelVector);
    final gyroVehicle = _calibration!.transformToVehicle(raw.gyroVector);

    // Remove gravity from accelerations
    // Vehicle Z should have ~-g when stationary (gravity pointing down)
    // We want to measure only dynamic accelerations
    final aLong = accelVehicle.x;
    final aLat = accelVehicle.y;
    final aVert = accelVehicle.z + G; // Add G to remove gravity component

    return VehicleSensorData(
      aLong: aLong,
      aLat: aLat,
      aVert: aVert,
      yawRate: gyroVehicle.z,
      pitchRate: gyroVehicle.y,
      rollRate: gyroVehicle.x,
      speedKmh: raw.speedKmh,
      speedMps: raw.speedMps,
      timestamp: raw.timestamp,
    );
  }

  /// Update calibration data
  void setCalibration(CalibrationData calibration) {
    _calibration = calibration;
  }

  /// Stop sensor data collection
  Future<void> stop() async {
    _dataTimer?.cancel();
    _dataTimer = null;

    await _accelSubscription?.cancel();
    _accelSubscription = null;

    await _gyroSubscription?.cancel();
    _gyroSubscription = null;

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    _isActive = false;
    notifyListeners();
  }

  /// Get current raw sensor data (for calibration)
  RawSensorData getRawData() {
    return RawSensorData(
      accelX: _accelX,
      accelY: _accelY,
      accelZ: _accelZ,
      gyroX: _gyroX,
      gyroY: _gyroY,
      gyroZ: _gyroZ,
      speedMps: _speedMps,
      timestamp: DateTime.now(),
    );
  }

  @override
  void dispose() {
    stop();
    _dataController.close();
    super.dispose();
  }
}

/// Mock sensor service for testing/simulation
class MockSensorService extends SensorService {
  Timer? _mockTimer;
  double _mockTime = 0;

  @override
  Future<void> start({CalibrationData? calibration}) async {
    if (_isActive) return;

    _calibration = calibration;
    _isActive = true;
    _mockTime = 0;

    // Simulate sensor data
    _mockTimer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ SENSOR_RATE_HZ),
      (_) {
        _mockTime += 1.0 / SENSOR_RATE_HZ;
        _generateMockData();
      },
    );

    notifyListeners();
  }

  void _generateMockData() {
    // Simulate a drive with some turns and braking
    final t = _mockTime;

    // Speed: accelerate to 50 km/h, then cruise
    double speedKmh;
    if (t < 10) {
      speedKmh = t * 5; // Accelerate
    } else {
      speedKmh = 50 + 10 * math.sin(t * 0.1); // Cruise with variation
    }

    // Simulate some turns
    double aLat = 2 * math.sin(t * 0.5);
    if (speedKmh < 5) aLat = 0;

    // Simulate braking/accel
    double aLong = math.sin(t * 0.3) * 1.5;
    if (speedKmh < 5) aLong = 0;

    // Add some jerk events occasionally
    if ((t * 10).floor() % 50 == 0) {
      aLat += (math.Random().nextDouble() - 0.5) * 4;
    }

    final data = VehicleSensorData(
      aLong: aLong,
      aLat: aLat,
      aVert: 0,
      yawRate: aLat / 10,
      pitchRate: 0,
      rollRate: 0,
      speedKmh: speedKmh.clamp(0, 120),
      speedMps: speedKmh / 3.6,
      timestamp: DateTime.now(),
    );

    _dataController.add(data);
  }

  @override
  Future<void> stop() async {
    _mockTimer?.cancel();
    _mockTimer = null;
    _isActive = false;
    notifyListeners();
  }
}
