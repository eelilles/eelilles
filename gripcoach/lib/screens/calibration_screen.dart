import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/app_state.dart';
import '../services/calibration_service.dart';

/// Screen for calibrating phone mount orientation
class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final CalibrationService _calibrationService = CalibrationService();
  CalibrationStatus _status = CalibrationStatus.idle;
  double _progress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calibrationService.progressStream.listen((result) {
      setState(() {
        _status = result.status;
        _progress = result.progress;
        _errorMessage = result.errorMessage;

        if (result.status == CalibrationStatus.success && result.data != null) {
          context.read<AppState>().setCalibration(result.data!);
        }
      });
    });
  }

  @override
  void dispose() {
    _calibrationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibrate Mount'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon based on status
            _buildStatusIcon(),
            const SizedBox(height: 32),

            // Instructions
            Text(
              _getInstructionText(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Secondary text
            Text(
              _getSecondaryText(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GripCoachTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Progress indicator or button
            if (_status == CalibrationStatus.capturing)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: GripCoachTheme.ledOff,
                    valueColor: const AlwaysStoppedAnimation(
                      GripCoachTheme.accentBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).round()}%',
                    style: TextStyle(color: GripCoachTheme.textSecondary),
                  ),
                ],
              )
            else if (_status == CalibrationStatus.processing)
              const CircularProgressIndicator()
            else if (_status == CalibrationStatus.failed)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GripCoachTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage ?? 'Calibration failed',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: GripCoachTheme.errorRed),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _startCalibration,
                    child: const Text('Try Again'),
                  ),
                ],
              )
            else if (_status == CalibrationStatus.success)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GripCoachTheme.successGreen,
                    ),
                    child: const Text('Done'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _startCalibration,
                    child: const Text('Recalibrate'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _startCalibration,
                child: const Text('Start Calibration'),
              ),

            const Spacer(),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GripCoachTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: GripCoachTheme.accentBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tips',
                        style: TextStyle(
                          color: GripCoachTheme.accentBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildTip('Mount phone securely on dashboard or windshield'),
                  _buildTip('Vehicle must be parked on level ground'),
                  _buildTip('Keep phone still during calibration'),
                  _buildTip('Engine can be running'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    double size = 80;

    switch (_status) {
      case CalibrationStatus.capturing:
        icon = Icons.sensors;
        color = GripCoachTheme.accentBlue;
        break;
      case CalibrationStatus.processing:
        icon = Icons.hourglass_empty;
        color = GripCoachTheme.accentBlue;
        break;
      case CalibrationStatus.success:
        icon = Icons.check_circle;
        color = GripCoachTheme.successGreen;
        break;
      case CalibrationStatus.failed:
        icon = Icons.error;
        color = GripCoachTheme.errorRed;
        break;
      case CalibrationStatus.idle:
      default:
        icon = Icons.phone_android;
        color = GripCoachTheme.textSecondary;
    }

    return Icon(icon, size: size, color: color);
  }

  String _getInstructionText() {
    switch (_status) {
      case CalibrationStatus.capturing:
        return 'Capturing sensor data...';
      case CalibrationStatus.processing:
        return 'Processing calibration...';
      case CalibrationStatus.success:
        return 'Calibration Complete!';
      case CalibrationStatus.failed:
        return 'Calibration Failed';
      case CalibrationStatus.idle:
      default:
        return 'Position Your Phone';
    }
  }

  String _getSecondaryText() {
    switch (_status) {
      case CalibrationStatus.capturing:
        return 'Keep the phone still';
      case CalibrationStatus.processing:
        return 'Please wait...';
      case CalibrationStatus.success:
        return 'Your phone orientation has been calibrated. '
            'You can now start a driving session.';
      case CalibrationStatus.failed:
        return 'Please try again';
      case CalibrationStatus.idle:
      default:
        return 'Mount your phone in the position you\'ll use while driving. '
            'Make sure it\'s secure and won\'t move.';
    }
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: GripCoachTheme.textSecondary)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: GripCoachTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startCalibration() async {
    setState(() {
      _status = CalibrationStatus.capturing;
      _progress = 0;
      _errorMessage = null;
    });

    await _calibrationService.startCalibration();
  }
}
