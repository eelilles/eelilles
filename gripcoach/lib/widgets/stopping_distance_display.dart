import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../services/stopping_calculator.dart';
import '../utils/conversions.dart';

/// Large stopping distance display widget
class StoppingDistanceDisplay extends StatelessWidget {
  /// Stopping distance calculation result
  final StoppingResult result;

  /// Whether to use metric units
  final bool isMetric;

  const StoppingDistanceDisplay({
    super.key,
    required this.result,
    this.isMetric = true,
  });

  @override
  Widget build(BuildContext context) {
    final totalDistance = isMetric
        ? result.totalDistanceM
        : result.totalDistanceFt;
    final unit = Conversions.distanceUnit(isMetric: isMetric);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Warning banner if stopping impossible
        if (result.warningMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: GripCoachTheme.warningOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GripCoachTheme.warningOrange),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: GripCoachTheme.warningOrange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.warningMessage!,
                    style: const TextStyle(
                      color: GripCoachTheme.warningOrange,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Main distance display
        Text(
          'Total Stopping Distance',
          style: TextStyle(
            fontSize: 16,
            color: GripCoachTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              totalDistance.round().toString(),
              style: const TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.bold,
                color: GripCoachTheme.textPrimary,
                height: 1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 32,
                color: GripCoachTheme.textSecondary,
              ),
            ),
          ],
        ),

        // Car lengths
        Text(
          '~${result.totalDistanceCarLengths.round()} car lengths',
          style: TextStyle(
            fontSize: 18,
            color: GripCoachTheme.textSecondary,
          ),
        ),

        const SizedBox(height: 24),

        // Breakdown
        _buildBreakdown(context),
      ],
    );
  }

  Widget _buildBreakdown(BuildContext context) {
    final reactionDist = isMetric
        ? result.reactionDistanceM
        : result.reactionDistanceFt;
    final brakingDist = isMetric
        ? result.brakingDistanceM
        : result.brakingDistanceFt;
    final unit = Conversions.distanceUnit(isMetric: isMetric);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GripCoachTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBreakdownItem(
            'Reaction',
            '${reactionDist.round()} $unit',
            Icons.psychology,
          ),
          Container(
            width: 1,
            height: 40,
            color: GripCoachTheme.textMuted,
          ),
          _buildBreakdownItem(
            'Braking',
            '${brakingDist.round()} $unit',
            Icons.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: GripCoachTheme.textMuted, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: GripCoachTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GripCoachTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
