import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/tuning_provider.dart';

/// Hidden developer tuning screen
class DevScreen extends StatelessWidget {
  const DevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Tuning'),
        backgroundColor: GripCoachTheme.accentPurple,
        actions: [
          TextButton(
            onPressed: () {
              context.read<TuningProvider>().resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset to defaults')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Consumer<TuningProvider>(
        builder: (context, tuning, child) {
          final params = tuning.params;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Smoothing Section
              _buildSectionHeader('Smoothing'),
              _buildSlider(
                label: 'Display Tau',
                value: params.displayTauS,
                min: 0.1,
                max: 2.0,
                unit: 's',
                onChanged: tuning.setDisplayTau,
              ),
              _buildSlider(
                label: 'Event Tau',
                value: params.eventTauS,
                min: 0.01,
                max: 0.5,
                unit: 's',
                onChanged: tuning.setEventTau,
              ),

              const SizedBox(height: 24),

              // Jerk Thresholds Section
              _buildSectionHeader('Jerk Thresholds'),
              _buildSlider(
                label: 'Yaw Jerk',
                value: params.jerkYawThreshold,
                min: 0.5,
                max: 5.0,
                unit: 'rad/s²',
                onChanged: tuning.setJerkYawThreshold,
              ),
              _buildSlider(
                label: 'Lateral Jerk',
                value: params.jerkLatThreshold,
                min: 1.0,
                max: 8.0,
                unit: 'm/s³',
                onChanged: tuning.setJerkLatThreshold,
              ),
              _buildSlider(
                label: 'Longitudinal Jerk',
                value: params.jerkLongThreshold,
                min: 1.0,
                max: 8.0,
                unit: 'm/s³',
                onChanged: tuning.setJerkLongThreshold,
              ),
              _buildSlider(
                label: 'Delta Yaw Rate',
                value: params.deltaYawRateThreshold,
                min: 0.1,
                max: 0.5,
                unit: 'rad/s',
                onChanged: tuning.setDeltaYawRateThreshold,
              ),

              const SizedBox(height: 24),

              // Motion Lock Section
              _buildSectionHeader('Motion Lock'),
              _buildSlider(
                label: 'Lock Speed',
                value: params.motionLockSpeedKmh,
                min: 2.0,
                max: 15.0,
                unit: 'km/h',
                onChanged: tuning.setMotionLockSpeed,
              ),
              _buildSlider(
                label: 'Unlock Speed',
                value: params.motionUnlockSpeedKmh,
                min: 0.5,
                max: 5.0,
                unit: 'km/h',
                onChanged: tuning.setMotionUnlockSpeed,
              ),
              _buildSlider(
                label: 'Unlock Duration',
                value: params.motionUnlockDurationS,
                min: 1.0,
                max: 10.0,
                unit: 's',
                onChanged: tuning.setMotionUnlockDuration,
              ),

              const SizedBox(height: 24),

              // Traction Thresholds Section
              _buildSectionHeader('Traction Thresholds'),
              _buildSlider(
                label: 'Green Threshold',
                value: params.greenThreshold,
                min: 0.3,
                max: 0.8,
                unit: '',
                onChanged: tuning.setGreenThreshold,
              ),
              _buildSlider(
                label: 'Yellow Threshold',
                value: params.yellowThreshold,
                min: 0.6,
                max: 0.95,
                unit: '',
                onChanged: tuning.setYellowThreshold,
              ),

              const SizedBox(height: 24),

              // Grade Estimation Section
              _buildSectionHeader('Grade Estimation'),
              _buildSlider(
                label: 'Grade Tau',
                value: params.gradeTauS,
                min: 2.0,
                max: 30.0,
                unit: 's',
                onChanged: tuning.setGradeTau,
              ),

              const SizedBox(height: 24),

              // Road Sensitivity Section
              _buildSectionHeader('Road Sensitivity'),
              _buildSlider(
                label: 'Dry',
                value: params.roadSensitivity['dry'] ?? 1.0,
                min: 0.5,
                max: 1.5,
                unit: '',
                onChanged: (v) => tuning.setRoadSensitivity('dry', v),
              ),
              _buildSlider(
                label: 'Wet',
                value: params.roadSensitivity['wet'] ?? 0.9,
                min: 0.5,
                max: 1.5,
                unit: '',
                onChanged: (v) => tuning.setRoadSensitivity('wet', v),
              ),
              _buildSlider(
                label: 'Snow',
                value: params.roadSensitivity['snow'] ?? 0.75,
                min: 0.3,
                max: 1.0,
                unit: '',
                onChanged: (v) => tuning.setRoadSensitivity('snow', v),
              ),
              _buildSlider(
                label: 'Ice',
                value: params.roadSensitivity['ice'] ?? 0.6,
                min: 0.3,
                max: 1.0,
                unit: '',
                onChanged: (v) => tuning.setRoadSensitivity('ice', v),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: GripCoachTheme.accentPurple,
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: GripCoachTheme.textSecondary)),
              Text(
                '${value.toStringAsFixed(2)} $unit',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: GripCoachTheme.accentPurple,
          ),
        ],
      ),
    );
  }
}
