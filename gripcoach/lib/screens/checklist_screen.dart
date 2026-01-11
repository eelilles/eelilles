import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/providers.dart';
import 'live_screen.dart';

/// Pre-drive checklist screen
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  bool _roadConditionsChecked = false;
  bool _dndEnabled = false;
  bool _phoneMounted = false;

  bool get _allChecked =>
      _roadConditionsChecked && _dndEnabled && _phoneMounted;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppState>().settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Drive Checklist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GripCoachTheme.warningOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GripCoachTheme.warningOrange),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: GripCoachTheme.warningOrange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Controls will lock when moving. Set all options before driving.',
                      style: TextStyle(
                        color: GripCoachTheme.warningOrange,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Checklist items
            _buildChecklistItem(
              title: 'Road conditions set correctly',
              subtitle: 'Current: ${settings.roadCondition.toUpperCase()} road',
              isChecked: _roadConditionsChecked,
              onChanged: (v) => setState(() => _roadConditionsChecked = v ?? false),
            ),

            const SizedBox(height: 12),

            _buildChecklistItem(
              title: 'Driving Focus / DND enabled',
              subtitle: 'Minimize distractions while driving',
              isChecked: _dndEnabled,
              onChanged: (v) => setState(() => _dndEnabled = v ?? false),
            ),

            const SizedBox(height: 12),

            _buildChecklistItem(
              title: 'Phone mounted securely',
              subtitle: 'Phone should not move during driving',
              isChecked: _phoneMounted,
              onChanged: (v) => setState(() => _phoneMounted = v ?? false),
            ),

            const Spacer(),

            // Current settings summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GripCoachTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingRow('Road', settings.roadCondition.toUpperCase()),
                  _buildSettingRow('Driver', settings.driverLevel),
                  _buildSettingRow('Units', settings.isMetric ? 'Metric' : 'Imperial'),
                  _buildSettingRow('View', settings.viewMode == 'bars'
                      ? 'Traction Bars' : 'Stopping Distance'),
                  if (!settings.autoGrade)
                    _buildSettingRow('Grade', '${settings.gradePercent >= 0 ? '+' : ''}${settings.gradePercent.round()}%'),
                  if (settings.autoGrade)
                    _buildSettingRow('Grade', 'Auto-estimate'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Back button
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Settings'),
            ),

            const SizedBox(height: 8),

            // Begin Drive button
            ElevatedButton(
              onPressed: _allChecked ? () => _beginDrive(context) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: GripCoachTheme.successGreen,
              ),
              child: const Text(
                'Begin Drive',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String title,
    required String subtitle,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isChecked
            ? GripCoachTheme.successGreen.withValues(alpha: 0.1)
            : GripCoachTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked
              ? GripCoachTheme.successGreen
              : GripCoachTheme.textMuted.withValues(alpha: 0.3),
        ),
      ),
      child: CheckboxListTile(
        value: isChecked,
        onChanged: onChanged,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: GripCoachTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        activeColor: GripCoachTheme.successGreen,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: GripCoachTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _beginDrive(BuildContext context) {
    final appState = context.read<AppState>();
    final sessionProvider = context.read<SessionProvider>();

    // Start the session
    sessionProvider.startSession(
      settings: appState.settings,
      calibration: appState.calibration,
    );

    // Navigate to live screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LiveScreen()),
    );
  }
}
