import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

/// Banner displayed when controls are locked due to motion
class MotionLockBanner extends StatelessWidget {
  /// Whether the banner should be shown
  final bool isVisible;

  const MotionLockBanner({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? 48 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: GripCoachTheme.lockBannerRed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                color: GripCoachTheme.lockBannerText,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  DISCLAIMER_MOTION_LOCK,
                  style: const TextStyle(
                    color: GripCoachTheme.lockBannerText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
