import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../utils/conversions.dart';

/// Card displaying recommended following distance
class FollowingDistanceCard extends StatelessWidget {
  /// Current speed in km/h
  final double speedKmh;

  /// Road condition for headway calculation
  final String roadCondition;

  /// Whether to use metric units
  final bool isMetric;

  const FollowingDistanceCard({
    super.key,
    required this.speedKmh,
    required this.roadCondition,
    this.isMetric = true,
  });

  @override
  Widget build(BuildContext context) {
    final headwaySeconds = HEADWAY_SECONDS[roadCondition] ?? 2;
    final speedMs = speedKmh * KMH_TO_MS;
    final distanceM = speedMs * headwaySeconds;
    final carLengths = distanceM / CAR_LENGTH_M;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GripCoachTheme.infoBlueDark.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GripCoachTheme.infoBlueDark.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.social_distance,
                color: GripCoachTheme.accentBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Following Distance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GripCoachTheme.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time-based
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$headwaySeconds sec',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: GripCoachTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'for $roadCondition',
                    style: const TextStyle(
                      fontSize: 12,
                      color: GripCoachTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              // Distance-based
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Conversions.formatDistance(distanceM, isMetric: isMetric),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: GripCoachTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '~${carLengths.round()} car lengths',
                    style: const TextStyle(
                      fontSize: 12,
                      color: GripCoachTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
