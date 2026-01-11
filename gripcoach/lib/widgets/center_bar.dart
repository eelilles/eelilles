import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

/// Center bar widget for accel/brake display (split vertically)
class CenterBar extends StatelessWidget {
  /// Acceleration fraction (0.0 to 1.0+) - fills top half
  final double accelFraction;

  /// Brake fraction (0.0 to 1.0+) - fills bottom half
  final double brakeFraction;

  /// Whether accel is active (vs brake)
  final bool isAccelerating;

  /// Number of segments per direction
  final int segmentsPerDirection;

  /// Width of the bar
  final double width;

  /// Total height of the bar
  final double height;

  const CenterBar({
    super.key,
    required this.accelFraction,
    required this.brakeFraction,
    required this.isAccelerating,
    this.segmentsPerDirection = 7,
    this.width = 50,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: isAccelerating ? accelFraction : brakeFraction,
      ),
      duration: Duration(milliseconds: LED_BAR_ANIMATION_MS),
      curve: Curves.easeOut,
      builder: (context, animatedFraction, child) {
        return CustomPaint(
          size: Size(width, height),
          painter: _CenterBarPainter(
            accelFraction: isAccelerating ? animatedFraction : 0,
            brakeFraction: isAccelerating ? 0 : animatedFraction,
            isAccelerating: isAccelerating,
            segmentsPerDirection: segmentsPerDirection,
          ),
        );
      },
    );
  }
}

class _CenterBarPainter extends CustomPainter {
  final double accelFraction;
  final double brakeFraction;
  final bool isAccelerating;
  final int segmentsPerDirection;

  _CenterBarPainter({
    required this.accelFraction,
    required this.brakeFraction,
    required this.isAccelerating,
    required this.segmentsPerDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final halfHeight = size.height / 2;
    final gap = 4.0; // Gap between accel and brake sections
    final sectionHeight = halfHeight - gap / 2;
    final segmentHeight =
        (sectionHeight - (segmentsPerDirection - 1) * 2) / segmentsPerDirection;
    final cornerRadius = Radius.circular(4);

    // Draw brake section (bottom half, fills upward from center)
    _drawSection(
      canvas,
      size,
      startY: halfHeight + gap / 2,
      segmentHeight: segmentHeight,
      fraction: brakeFraction,
      isActive: !isAccelerating && brakeFraction > 0,
      fillFromCenter: true,
    );

    // Draw accel section (top half, fills downward from center)
    _drawSection(
      canvas,
      size,
      startY: 0,
      segmentHeight: segmentHeight,
      fraction: accelFraction,
      isActive: isAccelerating && accelFraction > 0,
      fillFromCenter: false,
    );

    // Draw center line indicator
    final centerPaint = Paint()
      ..color = GripCoachTheme.textMuted
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, halfHeight),
      Offset(size.width, halfHeight),
      centerPaint,
    );
  }

  void _drawSection(
    Canvas canvas,
    Size size, {
    required double startY,
    required double segmentHeight,
    required double fraction,
    required bool isActive,
    required bool fillFromCenter,
  }) {
    final cornerRadius = Radius.circular(4);
    final litCount =
        (fraction * segmentsPerDirection).ceil().clamp(0, segmentsPerDirection);

    for (int i = 0; i < segmentsPerDirection; i++) {
      // Determine segment index based on fill direction
      final segmentIndex = fillFromCenter
          ? i
          : (segmentsPerDirection - 1 - i);

      final isLit = isActive && segmentIndex < litCount;

      // Calculate Y position
      final y = startY + i * (segmentHeight + 2);

      // Determine color
      Color color;
      if (!isActive) {
        color = GripCoachTheme.ledOff;
      } else if (!isLit) {
        // Dim color based on zone
        if (segmentIndex < segmentsPerDirection * GREEN_THRESHOLD) {
          color = GripCoachTheme.ledGreenDim;
        } else if (segmentIndex < segmentsPerDirection * YELLOW_THRESHOLD) {
          color = GripCoachTheme.ledYellowDim;
        } else {
          color = GripCoachTheme.ledRedDim;
        }
      } else {
        // Lit color based on zone
        if (segmentIndex < segmentsPerDirection * GREEN_THRESHOLD) {
          color = GripCoachTheme.tractionGreen;
        } else if (segmentIndex < segmentsPerDirection * YELLOW_THRESHOLD) {
          color = GripCoachTheme.tractionYellow;
        } else if (fraction > 1.0) {
          color = GripCoachTheme.tractionRedFlash;
        } else {
          color = GripCoachTheme.tractionRed;
        }
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y, size.width, segmentHeight),
        cornerRadius,
      );

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);

      // Add glow for lit segments
      if (isLit && isActive) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
        canvas.drawRRect(rect, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CenterBarPainter oldDelegate) {
    return accelFraction != oldDelegate.accelFraction ||
        brakeFraction != oldDelegate.brakeFraction ||
        isAccelerating != oldDelegate.isAccelerating;
  }
}
