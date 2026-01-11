import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/conversions.dart';

/// Large speed display widget
class SpeedDisplay extends StatelessWidget {
  /// Speed in km/h
  final double speedKmh;

  /// Whether to show in metric units
  final bool isMetric;

  /// Size of the display
  final SpeedDisplaySize size;

  const SpeedDisplay({
    super.key,
    required this.speedKmh,
    this.isMetric = true,
    this.size = SpeedDisplaySize.large,
  });

  @override
  Widget build(BuildContext context) {
    final displaySpeed = isMetric ? speedKmh : Conversions.kmhToMph(speedKmh);
    final unit = isMetric ? 'km/h' : 'mph';

    final fontSize = switch (size) {
      SpeedDisplaySize.small => 32.0,
      SpeedDisplaySize.medium => 48.0,
      SpeedDisplaySize.large => 64.0,
    };

    final unitSize = switch (size) {
      SpeedDisplaySize.small => 12.0,
      SpeedDisplaySize.medium => 16.0,
      SpeedDisplaySize.large => 20.0,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displaySpeed.round().toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: GripCoachTheme.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: unitSize,
            color: GripCoachTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

enum SpeedDisplaySize { small, medium, large }
