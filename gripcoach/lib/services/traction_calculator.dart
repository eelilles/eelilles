import 'dart:math' as math;

import '../config/constants.dart';
import '../models/session_settings.dart';
import 'signal_processor.dart';

/// Traction bar routing - which bar shows what
enum BarDirection {
  left,
  right,
  accel,
  brake,
}

/// Traction calculation result
class TractionResult {
  /// Longitudinal fraction (0-1+)
  final double longFrac;

  /// Lateral fraction (0-1+)
  final double latFrac;

  /// Combined friction circle fraction
  final double combinedFrac;

  /// Which lateral bar to show (left or right)
  final BarDirection latBar;

  /// Which center bar direction (accel or brake)
  final BarDirection longBar;

  /// Color zone: 'green', 'yellow', 'red', 'flash'
  final String colorZone;

  /// Raw a_long value (m/s²)
  final double aLong;

  /// Raw a_lat value (m/s²)
  final double aLat;

  const TractionResult({
    required this.longFrac,
    required this.latFrac,
    required this.combinedFrac,
    required this.latBar,
    required this.longBar,
    required this.colorZone,
    required this.aLong,
    required this.aLat,
  });

  factory TractionResult.zero() {
    return const TractionResult(
      longFrac: 0,
      latFrac: 0,
      combinedFrac: 0,
      latBar: BarDirection.left,
      longBar: BarDirection.brake,
      colorZone: 'green',
      aLong: 0,
      aLat: 0,
    );
  }
}

/// Calculates traction fractions from processed sensor data
class TractionCalculator {
  // Previous color for hysteresis
  String _previousColor = 'green';

  /// Calculate traction fractions
  TractionResult calculate(
    ProcessedSensorData data,
    SessionSettings settings,
  ) {
    final aLong = data.displayALong;
    final aLat = data.displayALat;

    // Get traction budget
    final muBudget = settings.tractionBudget;
    final maxAccel = G * muBudget;

    // Calculate fractions
    final longFrac = aLong.abs() / maxAccel;
    final latFrac = aLat.abs() / maxAccel;

    // Combined (friction circle)
    final combinedFrac = math.sqrt(aLong * aLong + aLat * aLat) / maxAccel;

    // Determine bar directions
    final latBar = aLat < 0 ? BarDirection.left : BarDirection.right;
    final longBar = aLong > 0 ? BarDirection.accel : BarDirection.brake;

    // Determine color zone with hysteresis
    final colorZone = _getColorWithHysteresis(combinedFrac);
    _previousColor = colorZone;

    return TractionResult(
      longFrac: longFrac,
      latFrac: latFrac,
      combinedFrac: combinedFrac,
      latBar: latBar,
      longBar: longBar,
      colorZone: colorZone,
      aLong: aLong,
      aLat: aLat,
    );
  }

  String _getColorWithHysteresis(double frac) {
    // Flash red for exceedance
    if (frac > 1.0) return 'flash';

    // Apply hysteresis based on previous color
    switch (_previousColor) {
      case 'green':
        if (frac >= GREEN_THRESHOLD + COLOR_HYSTERESIS) {
          return 'yellow';
        }
        return 'green';

      case 'yellow':
        if (frac >= YELLOW_THRESHOLD + COLOR_HYSTERESIS) {
          return 'red';
        }
        if (frac < GREEN_THRESHOLD - COLOR_HYSTERESIS) {
          return 'green';
        }
        return 'yellow';

      case 'red':
      case 'flash':
        if (frac < YELLOW_THRESHOLD - COLOR_HYSTERESIS) {
          return 'yellow';
        }
        return 'red';

      default:
        // First calculation or unknown state
        if (frac >= YELLOW_THRESHOLD) return 'red';
        if (frac >= GREEN_THRESHOLD) return 'yellow';
        return 'green';
    }
  }

  /// Reset hysteresis state
  void reset() {
    _previousColor = 'green';
  }
}
