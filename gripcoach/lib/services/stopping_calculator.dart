import 'dart:math' as math;

import '../config/constants.dart';
import '../models/session_settings.dart';

/// Stopping distance calculation result
class StoppingResult {
  /// Reaction distance (meters)
  final double reactionDistanceM;

  /// Braking distance (meters)
  final double brakingDistanceM;

  /// Total stopping distance (meters)
  final double totalDistanceM;

  /// Effective friction coefficient (mu + grade)
  final double effectiveMu;

  /// Whether stopping may be impossible
  final bool stoppingImpossible;

  /// Warning message if applicable
  final String? warningMessage;

  /// Speed used in calculation (km/h)
  final double speedKmh;

  /// Following distance recommendation (meters)
  final double followingDistanceM;

  /// Following distance in car lengths
  final double followingDistanceCarLengths;

  const StoppingResult({
    required this.reactionDistanceM,
    required this.brakingDistanceM,
    required this.totalDistanceM,
    required this.effectiveMu,
    required this.stoppingImpossible,
    this.warningMessage,
    required this.speedKmh,
    required this.followingDistanceM,
    required this.followingDistanceCarLengths,
  });

  factory StoppingResult.zero() {
    return const StoppingResult(
      reactionDistanceM: 0,
      brakingDistanceM: 0,
      totalDistanceM: 0,
      effectiveMu: 0.8,
      stoppingImpossible: false,
      speedKmh: 0,
      followingDistanceM: 0,
      followingDistanceCarLengths: 0,
    );
  }

  /// Get total distance in feet
  double get totalDistanceFt => totalDistanceM * METERS_TO_FEET;

  /// Get reaction distance in feet
  double get reactionDistanceFt => reactionDistanceM * METERS_TO_FEET;

  /// Get braking distance in feet
  double get brakingDistanceFt => brakingDistanceM * METERS_TO_FEET;

  /// Get following distance in feet
  double get followingDistanceFt => followingDistanceM * METERS_TO_FEET;

  /// Get total distance in car lengths
  double get totalDistanceCarLengths => totalDistanceM / CAR_LENGTH_M;
}

/// Calculates stopping distance based on speed, conditions, and grade
class StoppingCalculator {
  /// Calculate stopping distance
  StoppingResult calculate({
    required double speedKmh,
    required SessionSettings settings,
    double? gradePercent,
  }) {
    // Use provided grade or setting
    final grade = (gradePercent ?? settings.gradePercent) / 100.0;

    // Speed in m/s
    final v = speedKmh * KMH_TO_MS;

    // Get friction and driver parameters
    final muAvail = settings.frictionMu;
    final tReact = settings.reactionTime;

    // Effective friction with grade adjustment
    // Downhill (negative grade) reduces effective friction
    var effMu = muAvail + grade;

    // Check for impossible stopping
    bool stoppingImpossible = false;
    String? warningMessage;

    if (effMu <= 0.01) {
      effMu = 0.01; // Clamp to prevent division by zero
      stoppingImpossible = true;
      warningMessage =
          'Stopping may be impossible on this downhill grade for '
          '${settings.roadCondition} conditions.';
    } else if (effMu < muAvail * 0.3) {
      // Warn if grade significantly reduces available grip
      warningMessage =
          'Steep downhill significantly increases stopping distance.';
    }

    // Calculate distances
    final dReaction = v * tReact;
    final aBrake = G * effMu;
    final dBrake = (v * v) / (2 * aBrake);
    final dTotal = dReaction + dBrake;

    // Following distance based on headway time
    final headwaySeconds = settings.headwaySeconds;
    final followingDistanceM = v * headwaySeconds;
    final followingDistanceCarLengths = followingDistanceM / CAR_LENGTH_M;

    return StoppingResult(
      reactionDistanceM: dReaction,
      brakingDistanceM: dBrake,
      totalDistanceM: dTotal,
      effectiveMu: effMu,
      stoppingImpossible: stoppingImpossible,
      warningMessage: warningMessage,
      speedKmh: speedKmh,
      followingDistanceM: followingDistanceM,
      followingDistanceCarLengths: followingDistanceCarLengths,
    );
  }

  /// Calculate for imperial units (mph input, feet output)
  StoppingResult calculateImperial({
    required double speedMph,
    required SessionSettings settings,
    double? gradePercent,
  }) {
    // Convert mph to km/h and use metric calculation
    return calculate(
      speedKmh: speedMph / MPH_TO_MS * KMH_TO_MS,
      settings: settings,
      gradePercent: gradePercent,
    );
  }
}
