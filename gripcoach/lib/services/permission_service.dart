import 'package:geolocator/geolocator.dart';

/// Permission status for the app
class PermissionStatus {
  final bool locationEnabled;
  final bool locationPermissionGranted;
  final bool sensorsAvailable;
  final String? errorMessage;

  const PermissionStatus({
    required this.locationEnabled,
    required this.locationPermissionGranted,
    required this.sensorsAvailable,
    this.errorMessage,
  });

  bool get allGranted =>
      locationEnabled && locationPermissionGranted && sensorsAvailable;

  factory PermissionStatus.initial() {
    return const PermissionStatus(
      locationEnabled: false,
      locationPermissionGranted: false,
      sensorsAvailable: true, // Assume sensors available by default
    );
  }
}

/// Service for managing app permissions
class PermissionService {
  /// Check current permission status
  Future<PermissionStatus> checkPermissions() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      final locationGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      return PermissionStatus(
        locationEnabled: serviceEnabled,
        locationPermissionGranted: locationGranted,
        sensorsAvailable: true, // Sensors don't require permission on most devices
      );
    } catch (e) {
      return PermissionStatus(
        locationEnabled: false,
        locationPermissionGranted: false,
        sensorsAvailable: true,
        errorMessage: 'Error checking permissions: $e',
      );
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (for when permission is permanently denied)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get explanation for why we need location
  String get locationExplanation =>
      'GripCoach needs location access to calculate your current speed '
      'for traction and stopping distance displays. '
      'We only use location while the app is open and never track your position.';

  /// Get explanation for why we need motion sensors
  String get sensorExplanation =>
      'GripCoach uses motion sensors to detect braking, acceleration, '
      'and steering inputs for the traction display.';
}
