import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

/// Vertical LED bar widget for traction display
class LedBar extends StatelessWidget {
  /// Fraction of bar to fill (0.0 to 1.0+)
  final double fraction;

  /// Whether this bar is active (vs dim/inactive)
  final bool isActive;

  /// Whether the bar fills from bottom (default) or top
  final bool fillFromTop;

  /// Number of LED segments
  final int segments;

  /// Width of the bar
  final double width;

  /// Height of the bar
  final double height;

  const LedBar({
    super.key,
    required this.fraction,
    this.isActive = true,
    this.fillFromTop = false,
    this.segments = LED_BAR_SEGMENTS,
    this.width = 40,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isActive ? fraction : 0),
      duration: Duration(milliseconds: LED_BAR_ANIMATION_MS),
      curve: Curves.easeOut,
      builder: (context, animatedFraction, child) {
        return CustomPaint(
          size: Size(width, height),
          painter: _LedBarPainter(
            fraction: animatedFraction.clamp(0, 1.5),
            isActive: isActive,
            fillFromTop: fillFromTop,
            segments: segments,
          ),
        );
      },
    );
  }
}

class _LedBarPainter extends CustomPainter {
  final double fraction;
  final bool isActive;
  final bool fillFromTop;
  final int segments;

  _LedBarPainter({
    required this.fraction,
    required this.isActive,
    required this.fillFromTop,
    required this.segments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final segmentHeight = (size.height - (segments - 1) * 2) / segments;
    final segmentWidth = size.width;
    final cornerRadius = Radius.circular(4);

    // Calculate how many segments to light
    final litCount = (fraction * segments).ceil().clamp(0, segments);

    for (int i = 0; i < segments; i++) {
      // Segment index from the fill direction
      final segmentIndex = fillFromTop ? i : (segments - 1 - i);
      final isLit = isActive && segmentIndex < litCount;

      // Calculate segment position
      final y = i * (segmentHeight + 2);

      // Determine color based on segment position and lit state
      Color color;
      if (!isActive) {
        color = GripCoachTheme.ledOff;
      } else if (!isLit) {
        // Dim color based on zone
        if (segmentIndex < segments * GREEN_THRESHOLD) {
          color = GripCoachTheme.ledGreenDim;
        } else if (segmentIndex < segments * YELLOW_THRESHOLD) {
          color = GripCoachTheme.ledYellowDim;
        } else {
          color = GripCoachTheme.ledRedDim;
        }
      } else {
        // Lit color based on zone
        if (segmentIndex < segments * GREEN_THRESHOLD) {
          color = GripCoachTheme.tractionGreen;
        } else if (segmentIndex < segments * YELLOW_THRESHOLD) {
          color = GripCoachTheme.tractionYellow;
        } else if (fraction > 1.0) {
          color = GripCoachTheme.tractionRedFlash;
        } else {
          color = GripCoachTheme.tractionRed;
        }
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y, segmentWidth, segmentHeight),
        cornerRadius,
      );

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);

      // Add subtle glow for lit segments
      if (isLit && isActive) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
        canvas.drawRRect(rect, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_LedBarPainter oldDelegate) {
    return fraction != oldDelegate.fraction ||
        isActive != oldDelegate.isActive ||
        fillFromTop != oldDelegate.fillFromTop;
  }
}
