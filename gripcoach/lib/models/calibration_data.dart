import 'package:vector_math/vector_math_64.dart';

/// Calibration data for phone-to-vehicle frame transformation
class CalibrationData {
  /// 3x3 rotation matrix: phone frame → vehicle frame
  /// Vehicle frame: +X forward, +Y right, +Z up
  final Matrix3 transformMatrix;

  /// When calibration was performed
  final DateTime timestamp;

  /// Whether calibration is valid
  final bool isValid;

  /// Measured gravity magnitude during calibration (should be ~9.81)
  final double gravityMagnitude;

  /// Variance of measurements during calibration (should be low)
  final double measurementVariance;

  /// Raw gravity vector captured during calibration (phone frame)
  final Vector3 rawGravity;

  const CalibrationData({
    required this.transformMatrix,
    required this.timestamp,
    this.isValid = false,
    this.gravityMagnitude = 0.0,
    this.measurementVariance = 0.0,
    required this.rawGravity,
  });

  /// Create an invalid/empty calibration
  factory CalibrationData.invalid() {
    return CalibrationData(
      transformMatrix: Matrix3.identity(),
      timestamp: DateTime.now(),
      isValid: false,
      rawGravity: Vector3.zero(),
    );
  }

  /// Transform a vector from phone frame to vehicle frame
  Vector3 transformToVehicle(Vector3 phoneFrame) {
    return transformMatrix.transformed(phoneFrame);
  }

  /// Get vehicle-frame accelerations from phone-frame accelerations
  /// Returns (a_long, a_lat, a_vert) where:
  /// - a_long: forward (+) / braking (-)
  /// - a_lat: right (+) / left (-)
  /// - a_vert: up (+) / down (-)
  (double, double, double) getVehicleAccel(
    double phoneX,
    double phoneY,
    double phoneZ,
  ) {
    final phoneAccel = Vector3(phoneX, phoneY, phoneZ);
    final vehicleAccel = transformToVehicle(phoneAccel);
    return (vehicleAccel.x, vehicleAccel.y, vehicleAccel.z);
  }

  /// Copy with new values
  CalibrationData copyWith({
    Matrix3? transformMatrix,
    DateTime? timestamp,
    bool? isValid,
    double? gravityMagnitude,
    double? measurementVariance,
    Vector3? rawGravity,
  }) {
    return CalibrationData(
      transformMatrix: transformMatrix ?? this.transformMatrix,
      timestamp: timestamp ?? this.timestamp,
      isValid: isValid ?? this.isValid,
      gravityMagnitude: gravityMagnitude ?? this.gravityMagnitude,
      measurementVariance: measurementVariance ?? this.measurementVariance,
      rawGravity: rawGravity ?? this.rawGravity,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'transformMatrix': transformMatrix.storage.toList(),
      'timestamp': timestamp.toIso8601String(),
      'isValid': isValid,
      'gravityMagnitude': gravityMagnitude,
      'measurementVariance': measurementVariance,
      'rawGravity': [rawGravity.x, rawGravity.y, rawGravity.z],
    };
  }

  /// Create from JSON map
  factory CalibrationData.fromJson(Map<String, dynamic> json) {
    final matrixStorage = (json['transformMatrix'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    final matrix = Matrix3.fromList(matrixStorage);

    final gravityList = json['rawGravity'] as List<dynamic>;
    final rawGravity = Vector3(
      (gravityList[0] as num).toDouble(),
      (gravityList[1] as num).toDouble(),
      (gravityList[2] as num).toDouble(),
    );

    return CalibrationData(
      transformMatrix: matrix,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isValid: json['isValid'] as bool? ?? false,
      gravityMagnitude: (json['gravityMagnitude'] as num?)?.toDouble() ?? 0.0,
      measurementVariance:
          (json['measurementVariance'] as num?)?.toDouble() ?? 0.0,
      rawGravity: rawGravity,
    );
  }

  @override
  String toString() {
    return 'CalibrationData(valid: $isValid, gravity: $gravityMagnitude, '
        'variance: $measurementVariance)';
  }
}
