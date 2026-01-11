/// A single data point captured during a session
/// Used for post-drive analysis and timeline visualization
class DataPoint {
  /// Timestamp of the data point
  final DateTime timestamp;

  /// Speed in km/h
  final double speedKmh;

  /// Combined traction fraction (0.0 - 1.0+)
  final double combinedFrac;

  /// Longitudinal fraction (for center bar)
  final double longFrac;

  /// Lateral fraction (for left/right bars)
  final double latFrac;

  /// Current grade percentage
  final double gradePercent;

  /// Traction color zone: 'green', 'yellow', 'red'
  final String colorZone;

  const DataPoint({
    required this.timestamp,
    required this.speedKmh,
    required this.combinedFrac,
    required this.longFrac,
    required this.latFrac,
    required this.gradePercent,
    required this.colorZone,
  });

  /// Get color zone from combined fraction
  static String getColorZone(double fraction) {
    if (fraction >= 0.85) return 'red';
    if (fraction >= 0.60) return 'yellow';
    return 'green';
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'speedKmh': speedKmh,
      'combinedFrac': combinedFrac,
      'longFrac': longFrac,
      'latFrac': latFrac,
      'gradePercent': gradePercent,
      'colorZone': colorZone,
    };
  }

  /// Create from JSON map
  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      speedKmh: (json['speedKmh'] as num).toDouble(),
      combinedFrac: (json['combinedFrac'] as num).toDouble(),
      longFrac: (json['longFrac'] as num).toDouble(),
      latFrac: (json['latFrac'] as num).toDouble(),
      gradePercent: (json['gradePercent'] as num).toDouble(),
      colorZone: json['colorZone'] as String,
    );
  }

  @override
  String toString() {
    return 'DataPoint(${timestamp.toIso8601String()}, '
        'speed: ${speedKmh.toStringAsFixed(1)}, '
        'frac: ${combinedFrac.toStringAsFixed(2)}, '
        'zone: $colorZone)';
  }
}
