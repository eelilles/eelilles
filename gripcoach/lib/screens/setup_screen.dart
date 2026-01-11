import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/grade_display.dart';
import 'calibration_screen.dart';
import 'checklist_screen.dart';
import 'dev_screen.dart';

/// Setup screen for configuring session settings
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _devTapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GripCoach'),
        actions: [
          // Hidden dev button - tap 7 times
          GestureDetector(
            onTap: _handleDevTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.settings,
                color: GripCoachTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final settings = appState.settings;
          final isCalibrated = appState.isCalibrated;
          final isMoving = context.watch<SessionProvider>().isMoving;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Road Condition
                    _buildSectionTitle('Road Condition'),
                    const SizedBox(height: 8),
                    _buildRoadConditionButtons(settings, appState, isMoving),
                    const SizedBox(height: 24),

                    // Driver Level
                    _buildSectionTitle('Driver Level'),
                    const SizedBox(height: 8),
                    _buildDriverLevelButtons(settings, appState, isMoving),
                    const SizedBox(height: 24),

                    // Units
                    _buildSectionTitle('Units'),
                    const SizedBox(height: 8),
                    _buildUnitsToggle(settings, appState, isMoving),
                    const SizedBox(height: 24),

                    // View Mode
                    _buildSectionTitle('View Mode'),
                    const SizedBox(height: 8),
                    _buildViewModeButtons(settings, appState, isMoving),
                    const SizedBox(height: 24),

                    // Grade
                    _buildGradeSection(settings, appState, isMoving),
                    const SizedBox(height: 32),

                    // Calibration Status
                    _buildCalibrationCard(appState, isMoving),
                    const SizedBox(height: 16),

                    // Start Session Button
                    ElevatedButton(
                      onPressed: isCalibrated && !isMoving
                          ? () => _startSession(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: GripCoachTheme.successGreen,
                      ),
                      child: const Text(
                        'Start Session',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Disclaimer
                    Text(
                      DISCLAIMER_SETUP_FOOTER,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: GripCoachTheme.textMuted,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Motion lock overlay
              if (isMoving)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: GripCoachTheme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock,
                              size: 48,
                              color: GripCoachTheme.errorRed,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Controls Locked',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DISCLAIMER_MOTION_LOCK,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: GripCoachTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildRoadConditionButtons(
    SessionSettings settings,
    AppState appState,
    bool isMoving,
  ) {
    return Row(
      children: [
        _buildOptionButton(
          label: 'Dry',
          isSelected: settings.roadCondition == 'dry',
          onTap: isMoving ? null : () => appState.setRoadCondition('dry'),
          color: GripCoachTheme.successGreen,
        ),
        const SizedBox(width: 8),
        _buildOptionButton(
          label: 'Wet',
          isSelected: settings.roadCondition == 'wet',
          onTap: isMoving ? null : () => appState.setRoadCondition('wet'),
          color: GripCoachTheme.accentBlue,
        ),
        const SizedBox(width: 8),
        _buildOptionButton(
          label: 'Snow',
          isSelected: settings.roadCondition == 'snow',
          onTap: isMoving ? null : () => appState.setRoadCondition('snow'),
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        _buildOptionButton(
          label: 'Ice',
          isSelected: settings.roadCondition == 'ice',
          onTap: isMoving ? null : () => appState.setRoadCondition('ice'),
          color: Colors.lightBlue,
        ),
      ],
    );
  }

  Widget _buildDriverLevelButtons(
    SessionSettings settings,
    AppState appState,
    bool isMoving,
  ) {
    return Row(
      children: [
        _buildOptionButton(
          label: 'New',
          isSelected: settings.driverLevel == 'new',
          onTap: isMoving ? null : () => appState.setDriverLevel('new'),
        ),
        const SizedBox(width: 8),
        _buildOptionButton(
          label: 'Intermediate',
          isSelected: settings.driverLevel == 'intermediate',
          onTap: isMoving ? null : () => appState.setDriverLevel('intermediate'),
        ),
        const SizedBox(width: 8),
        _buildOptionButton(
          label: 'Experienced',
          isSelected: settings.driverLevel == 'experienced',
          onTap: isMoving ? null : () => appState.setDriverLevel('experienced'),
        ),
      ],
    );
  }

  Widget _buildUnitsToggle(
    SessionSettings settings,
    AppState appState,
    bool isMoving,
  ) {
    return Row(
      children: [
        _buildOptionButton(
          label: 'Metric (km/h, m)',
          isSelected: settings.units == 'metric',
          onTap: isMoving ? null : () => appState.setUnits('metric'),
          flex: 1,
        ),
        const SizedBox(width: 8),
        _buildOptionButton(
          label: 'Imperial (mph, ft)',
          isSelected: settings.units == 'imperial',
          onTap: isMoving ? null : () => appState.setUnits('imperial'),
          flex: 1,
        ),
      ],
    );
  }

  Widget _buildViewModeButtons(
    SessionSettings settings,
    AppState appState,
    bool isMoving,
  ) {
    return Row(
      children: [
        _buildOptionButton(
          label: 'Traction Bars',
          isSelected: settings.viewMode == 'bars',
          onTap: isMoving ? null : () => appState.setViewMode('bars'),
          flex: 1,
        ),
        const SizedBox(width: 8),
        _buildOptionButton(
          label: 'Stopping Distance',
          isSelected: settings.viewMode == 'distance',
          onTap: isMoving ? null : () => appState.setViewMode('distance'),
          flex: 1,
        ),
      ],
    );
  }

  Widget _buildGradeSection(
    SessionSettings settings,
    AppState appState,
    bool isMoving,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Grade'),
            // Auto-grade toggle
            Row(
              children: [
                Text(
                  'Auto',
                  style: TextStyle(
                    color: settings.autoGrade
                        ? GripCoachTheme.accentPurple
                        : GripCoachTheme.textMuted,
                  ),
                ),
                Switch(
                  value: settings.autoGrade,
                  onChanged: isMoving ? null : (v) => appState.setAutoGrade(v),
                  activeColor: GripCoachTheme.accentPurple,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (settings.autoGrade)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GripCoachTheme.accentPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GripCoachTheme.accentPurple),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: GripCoachTheme.accentPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Grade will be estimated automatically during steady driving.',
                    style: TextStyle(
                      color: GripCoachTheme.accentPurple,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          GradeSlider(
            value: settings.gradePercent,
            onChanged: (v) => appState.setGradePercent(v),
            enabled: !isMoving,
          ),
      ],
    );
  }

  Widget _buildCalibrationCard(AppState appState, bool isMoving) {
    final isCalibrated = appState.isCalibrated;

    return Card(
      color: isCalibrated
          ? GripCoachTheme.successGreen.withValues(alpha: 0.1)
          : GripCoachTheme.warningOrange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isCalibrated ? Icons.check_circle : Icons.warning,
              color: isCalibrated
                  ? GripCoachTheme.successGreen
                  : GripCoachTheme.warningOrange,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCalibrated ? 'Mount Calibrated' : 'Calibration Required',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    isCalibrated
                        ? 'Phone orientation is set'
                        : 'Mount phone and calibrate before driving',
                    style: TextStyle(
                      color: GripCoachTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: isMoving
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalibrationScreen(),
                        ),
                      );
                    },
              child: Text(isCalibrated ? 'Recalibrate' : 'Calibrate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
    Color? color,
    int flex = 0,
  }) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? GripCoachTheme.accentBlue).withValues(alpha: 0.2)
              : GripCoachTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (color ?? GripCoachTheme.accentBlue)
                : GripCoachTheme.textMuted.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onTap == null
                ? GripCoachTheme.textMuted
                : (isSelected
                    ? (color ?? GripCoachTheme.accentBlue)
                    : GripCoachTheme.textPrimary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );

    if (flex > 0) {
      return Expanded(flex: flex, child: button);
    }
    return Expanded(child: button);
  }

  void _handleDevTap() {
    _devTapCount++;
    if (_devTapCount >= 7) {
      _devTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DevScreen()),
      );
    }
  }

  void _startSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChecklistScreen()),
    );
  }
}
