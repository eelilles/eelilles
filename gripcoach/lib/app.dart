import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'screens/setup_screen.dart';

/// Main GripCoach application widget
class GripCoachApp extends StatelessWidget {
  const GripCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GripCoach',
      debugShowCheckedModeBanner: false,
      theme: GripCoachTheme.darkTheme,
      home: const SetupScreen(),
    );
  }
}
