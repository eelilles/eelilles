import '../config/constants.dart';

/// Unit conversion utilities
class Conversions {
  /// Convert km/h to m/s
  static double kmhToMs(double kmh) => kmh * KMH_TO_MS;

  /// Convert m/s to km/h
  static double msToKmh(double ms) => ms / KMH_TO_MS;

  /// Convert mph to m/s
  static double mphToMs(double mph) => mph * MPH_TO_MS;

  /// Convert m/s to mph
  static double msToMph(double ms) => ms / MPH_TO_MS;

  /// Convert km/h to mph
  static double kmhToMph(double kmh) => kmh * KMH_TO_MS / MPH_TO_MS;

  /// Convert mph to km/h
  static double mphToKmh(double mph) => mph * MPH_TO_MS / KMH_TO_MS;

  /// Convert meters to feet
  static double metersToFeet(double m) => m * METERS_TO_FEET;

  /// Convert feet to meters
  static double feetToMeters(double ft) => ft / METERS_TO_FEET;

  /// Convert meters to car lengths
  static double metersToCarLengths(double m) => m / CAR_LENGTH_M;

  /// Format speed based on units
  static String formatSpeed(double speedKmh, {bool isMetric = true}) {
    if (isMetric) {
      return '${speedKmh.round()} km/h';
    } else {
      return '${kmhToMph(speedKmh).round()} mph';
    }
  }

  /// Format distance based on units
  static String formatDistance(double distanceM, {bool isMetric = true}) {
    if (isMetric) {
      if (distanceM < 10) {
        return '${distanceM.toStringAsFixed(1)} m';
      }
      return '${distanceM.round()} m';
    } else {
      final feet = metersToFeet(distanceM);
      if (feet < 30) {
        return '${feet.toStringAsFixed(1)} ft';
      }
      return '${feet.round()} ft';
    }
  }

  /// Format large distance (for stopping distance display)
  static String formatLargeDistance(double distanceM, {bool isMetric = true}) {
    if (isMetric) {
      return '${distanceM.round()}';
    } else {
      return '${metersToFeet(distanceM).round()}';
    }
  }

  /// Get distance unit label
  static String distanceUnit({bool isMetric = true}) {
    return isMetric ? 'm' : 'ft';
  }

  /// Get speed unit label
  static String speedUnit({bool isMetric = true}) {
    return isMetric ? 'km/h' : 'mph';
  }

  /// Format grade percentage
  static String formatGrade(double gradePercent) {
    final sign = gradePercent >= 0 ? '+' : '';
    return '$sign${gradePercent.toStringAsFixed(1)}%';
  }

  /// Format time duration (seconds) to mm:ss
  static String formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).round();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format timestamp to HH:mm:ss
  static String formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Format date to readable string
  static String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
