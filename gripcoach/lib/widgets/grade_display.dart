import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/conversions.dart';

/// Widget to display current grade
class GradeDisplay extends StatelessWidget {
  /// Current grade percentage
  final double gradePercent;

  /// Whether auto-grade is enabled
  final bool isAutoGrade;

  /// Whether we're in steady state (updating)
  final bool inSteadyState;

  /// Whether the display is compact
  final bool compact;

  const GradeDisplay({
    super.key,
    required this.gradePercent,
    this.isAutoGrade = false,
    this.inSteadyState = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDownhill = gradePercent < 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: isAutoGrade
            ? GripCoachTheme.accentPurple.withValues(alpha: 0.2)
            : GripCoachTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: isAutoGrade
            ? Border.all(color: GripCoachTheme.accentPurple, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grade icon
          Icon(
            isDownhill ? Icons.trending_down : Icons.trending_up,
            color: isDownhill
                ? GripCoachTheme.tractionYellow
                : GripCoachTheme.textSecondary,
            size: compact ? 16 : 20,
          ),
          SizedBox(width: compact ? 4 : 8),

          // Grade value
          Text(
            Conversions.formatGrade(gradePercent),
            style: TextStyle(
              fontSize: compact ? 14 : 18,
              fontWeight: FontWeight.bold,
              color: GripCoachTheme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          // Auto-grade indicator
          if (isAutoGrade) ...[
            SizedBox(width: compact ? 4 : 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: GripCoachTheme.accentPurple.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                inSteadyState ? 'est' : 'paused',
                style: TextStyle(
                  fontSize: compact ? 10 : 12,
                  color: GripCoachTheme.accentPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Grade slider widget for setup screen
class GradeSlider extends StatelessWidget {
  /// Current grade value
  final double value;

  /// Callback when value changes
  final ValueChanged<double> onChanged;

  /// Whether the slider is enabled
  final bool enabled;

  const GradeSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Grade',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            GradeDisplay(gradePercent: value, compact: true),
          ],
        ),
        const SizedBox(height: 8),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: enabled
                ? GripCoachTheme.accentBlue
                : GripCoachTheme.textMuted,
            inactiveTrackColor: GripCoachTheme.ledOff,
            thumbColor: enabled
                ? GripCoachTheme.accentBlue
                : GripCoachTheme.textMuted,
            overlayColor: GripCoachTheme.accentBlue.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: -12,
            max: 12,
            divisions: 24,
            onChanged: enabled ? onChanged : null,
          ),
        ),

        // Preset buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _presetButton(context, -10),
            _presetButton(context, -6),
            _presetButton(context, -3),
            _presetButton(context, 0),
            _presetButton(context, 3),
            _presetButton(context, 6),
            _presetButton(context, 10),
          ],
        ),
      ],
    );
  }

  Widget _presetButton(BuildContext context, double presetValue) {
    final isSelected = (value - presetValue).abs() < 0.5;
    final label = presetValue >= 0 ? '+${presetValue.round()}' : '${presetValue.round()}';

    return GestureDetector(
      onTap: enabled ? () => onChanged(presetValue) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? GripCoachTheme.accentBlue
              : GripCoachTheme.cardColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (enabled
                    ? GripCoachTheme.textSecondary
                    : GripCoachTheme.textMuted),
          ),
        ),
      ),
    );
  }
}
