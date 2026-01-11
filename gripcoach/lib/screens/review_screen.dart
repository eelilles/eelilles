import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/models.dart';
import '../utils/conversions.dart';
import 'setup_screen.dart';

/// Session review screen showing summary and events
class ReviewScreen extends StatelessWidget {
  final SessionData session;

  const ReviewScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Review'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Session info
            _buildSessionInfoCard(context),

            const SizedBox(height: 16),

            // Traction usage breakdown
            _buildTractionUsageCard(context),

            const SizedBox(height: 16),

            // Events list
            if (session.events.isNotEmpty) ...[
              _buildEventsCard(context),
              const SizedBox(height: 16),
            ],

            // Debrief notes
            if (session.debriefNotes.isNotEmpty) ...[
              _buildNotesCard(context),
              const SizedBox(height: 16),
            ],

            // Summary
            _buildSummaryCard(context),

            const SizedBox(height: 32),

            // New Session button
            ElevatedButton(
              onPressed: () => _startNewSession(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'New Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard(BuildContext context) {
    final duration = session.totalTimeSeconds;
    final settings = session.settings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GripCoachTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Conversions.formatDate(session.startTime),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                Conversions.formatDuration(duration),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(settings.roadCondition.toUpperCase()),
              const SizedBox(width: 8),
              _buildInfoChip(settings.driverLevel),
              const SizedBox(width: 8),
              _buildInfoChip(settings.isMetric ? 'Metric' : 'Imperial'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: GripCoachTheme.primaryLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildTractionUsageCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GripCoachTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Traction Usage',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Green bar
          _buildUsageBar(
            label: 'Safe Zone',
            percentage: session.greenPercent,
            color: GripCoachTheme.tractionGreen,
          ),
          const SizedBox(height: 8),

          // Yellow bar
          _buildUsageBar(
            label: 'Caution Zone',
            percentage: session.yellowPercent,
            color: GripCoachTheme.tractionYellow,
          ),
          const SizedBox(height: 8),

          // Red bar
          _buildUsageBar(
            label: 'Danger Zone',
            percentage: session.redPercent,
            color: GripCoachTheme.tractionRed,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar({
    required String label,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: GripCoachTheme.textSecondary)),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: GripCoachTheme.ledOff,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildEventsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GripCoachTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Teachable Moments',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GripCoachTheme.warningOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${session.events.length}',
                  style: TextStyle(
                    color: GripCoachTheme.warningOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...session.events.take(5).map((event) => _buildEventItem(event)),
          if (session.events.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${session.events.length - 5} more events',
                style: TextStyle(color: GripCoachTheme.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventItem(DrivingEvent event) {
    IconData icon;
    Color color;

    switch (event.type) {
      case DrivingEventType.steeringJerk:
        icon = Icons.turn_right;
        color = GripCoachTheme.accentBlue;
        break;
      case DrivingEventType.brakeJerk:
        icon = Icons.warning;
        color = GripCoachTheme.tractionYellow;
        break;
      case DrivingEventType.tractionExceedance:
        icon = Icons.error;
        color = GripCoachTheme.tractionRed;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.typeName,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${Conversions.formatTimestamp(event.timestamp)} at ${event.speedKmh.round()} km/h',
                  style: TextStyle(
                    color: GripCoachTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GripCoachTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Notes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (session.debriefNotes['slippery'] != null)
            _buildNoteItem('Slippery moments', session.debriefNotes['slippery']!),
          if (session.debriefNotes['braking'] != null)
            _buildNoteItem('Braking', session.debriefNotes['braking']!),
          if (session.debriefNotes['steering'] != null)
            _buildNoteItem('Steering', session.debriefNotes['steering']!),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String label, String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: GripCoachTheme.accentBlue,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          Text(
            note,
            style: TextStyle(color: GripCoachTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final goodSession = session.greenPercent > 70 && session.events.length < 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: goodSession
            ? GripCoachTheme.successGreen.withValues(alpha: 0.1)
            : GripCoachTheme.accentBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goodSession
              ? GripCoachTheme.successGreen
              : GripCoachTheme.accentBlue,
        ),
      ),
      child: Column(
        children: [
          Icon(
            goodSession ? Icons.thumb_up : Icons.school,
            color: goodSession
                ? GripCoachTheme.successGreen
                : GripCoachTheme.accentBlue,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            goodSession ? 'Great driving!' : 'Keep practicing!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: goodSession
                  ? GripCoachTheme.successGreen
                  : GripCoachTheme.accentBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            goodSession
                ? 'You maintained good control throughout most of the session.'
                : 'Focus on smoother inputs and maintaining safe traction margins.',
            textAlign: TextAlign.center,
            style: TextStyle(color: GripCoachTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _startNewSession(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SetupScreen()),
      (route) => false,
    );
  }
}
