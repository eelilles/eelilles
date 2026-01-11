import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Label showing current driving smoothness
class SmoothnessLabel extends StatelessWidget {
  /// Whether driving is currently choppy
  final bool isChoppy;

  const SmoothnessLabel({
    super.key,
    required this.isChoppy,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isChoppy
            ? GripCoachTheme.warningOrange.withValues(alpha: 0.2)
            : GripCoachTheme.successGreen.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isChoppy
              ? GripCoachTheme.warningOrange
              : GripCoachTheme.successGreen,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isChoppy ? Icons.waves : Icons.check_circle_outline,
            color: isChoppy
                ? GripCoachTheme.warningOrange
                : GripCoachTheme.successGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isChoppy ? 'Choppy' : 'Smooth',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isChoppy
                  ? GripCoachTheme.warningOrange
                  : GripCoachTheme.successGreen,
            ),
          ),
        ],
      ),
    );
  }
}
