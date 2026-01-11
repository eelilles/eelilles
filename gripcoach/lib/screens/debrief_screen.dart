import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/session_data.dart';
import '../services/storage_service.dart';
import 'review_screen.dart';

/// Post-drive debrief screen for reflection
class DebriefScreen extends StatefulWidget {
  final SessionData session;

  const DebriefScreen({super.key, required this.session});

  @override
  State<DebriefScreen> createState() => _DebriefScreenState();
}

class _DebriefScreenState extends State<DebriefScreen> {
  final _slipperyController = TextEditingController();
  final _brakingController = TextEditingController();
  final _steeringController = TextEditingController();

  @override
  void dispose() {
    _slipperyController.dispose();
    _brakingController.dispose();
    _steeringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drive Debrief'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Take a moment to reflect on your drive',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'These notes will help you learn from this session.',
              style: TextStyle(color: GripCoachTheme.textSecondary),
            ),

            const SizedBox(height: 24),

            // Question 1
            _buildQuestionCard(
              question: 'What moments felt slippery or uncertain?',
              hint: 'Think about turns, braking zones, or surfaces...',
              controller: _slipperyController,
              icon: Icons.warning_amber,
              iconColor: GripCoachTheme.tractionYellow,
            ),

            const SizedBox(height: 16),

            // Question 2
            _buildQuestionCard(
              question: 'Where did you brake too late or too hard?',
              hint: 'Approaching intersections, curves, traffic...',
              controller: _brakingController,
              icon: Icons.speed,
              iconColor: GripCoachTheme.tractionRed,
            ),

            const SizedBox(height: 16),

            // Question 3
            _buildQuestionCard(
              question: 'Where was steering choppy or jerky?',
              hint: 'Lane changes, parking, tight turns...',
              controller: _steeringController,
              icon: Icons.turn_right,
              iconColor: GripCoachTheme.accentBlue,
            ),

            const SizedBox(height: 32),

            // Skip button
            TextButton(
              onPressed: () => _continueToReview(skipNotes: true),
              child: Text(
                'Skip for now',
                style: TextStyle(color: GripCoachTheme.textSecondary),
              ),
            ),

            const SizedBox(height: 8),

            // Continue button
            ElevatedButton(
              onPressed: () => _continueToReview(skipNotes: false),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Continue to Review',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String question,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
  }) {
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
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: GripCoachTheme.textMuted),
              filled: true,
              fillColor: GripCoachTheme.primaryDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _continueToReview({required bool skipNotes}) async {
    // Collect notes
    final notes = <String, String>{};
    if (!skipNotes) {
      if (_slipperyController.text.isNotEmpty) {
        notes['slippery'] = _slipperyController.text;
      }
      if (_brakingController.text.isNotEmpty) {
        notes['braking'] = _brakingController.text;
      }
      if (_steeringController.text.isNotEmpty) {
        notes['steering'] = _steeringController.text;
      }
    }

    // Update session with notes
    final updatedSession = widget.session.copyWith(debriefNotes: notes);

    // Save session
    final storageService = StorageService();
    await storageService.saveSession(updatedSession);

    if (!mounted) return;

    // Navigate to review
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(session: updatedSession),
      ),
    );
  }
}
