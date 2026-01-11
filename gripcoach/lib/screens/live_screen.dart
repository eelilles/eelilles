import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'debrief_screen.dart';

/// Live driving session screen
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  late SensorService _sensorService;
  late SignalProcessor _signalProcessor;
  late TractionCalculator _tractionCalculator;
  late StoppingCalculator _stoppingCalculator;
  late JerkDetector _jerkDetector;
  late GradeEstimator _gradeEstimator;

  StreamSubscription? _sensorSubscription;

  TractionResult _tractionResult = TractionResult.zero();
  StoppingResult _stoppingResult = StoppingResult.zero();

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  void _initServices() {
    // Use mock sensor service for testing - replace with real SensorService for production
    _sensorService = MockSensorService();
    _signalProcessor = SignalProcessor();
    _tractionCalculator = TractionCalculator();
    _stoppingCalculator = StoppingCalculator();
    _jerkDetector = JerkDetector();
    _gradeEstimator = GradeEstimator();

    final appState = context.read<AppState>();
    final settings = appState.settings;

    // Initialize grade estimator with manual setting
    if (!settings.autoGrade) {
      _gradeEstimator.setInitialGrade(settings.gradePercent);
    }

    // Start sensors
    _sensorService.start(calibration: appState.calibration);

    // Listen to sensor data
    _sensorSubscription = _sensorService.dataStream.listen(_processSensorData);
  }

  void _processSensorData(VehicleSensorData vehicleData) {
    if (!mounted) return;

    final sessionProvider = context.read<SessionProvider>();
    final appState = context.read<AppState>();
    final settings = appState.settings;

    // Process through signal chain
    final processed = _signalProcessor.process(vehicleData);

    // Update grade estimate if auto-grade enabled
    double gradePercent = settings.gradePercent;
    bool gradeInSteadyState = false;

    if (settings.autoGrade) {
      final gradeEstimate = _gradeEstimator.update(vehicleData, processed);
      gradePercent = gradeEstimate.gradePercent;
      gradeInSteadyState = gradeEstimate.inSteadyState;
    }

    // Calculate traction
    final tractionResult = _tractionCalculator.calculate(processed, settings);

    // Calculate stopping distance
    final stoppingResult = _stoppingCalculator.calculate(
      speedKmh: processed.speedKmh,
      settings: settings,
      gradePercent: gradePercent,
    );

    // Detect jerk events
    final jerkResult = _jerkDetector.detect(processed, settings);
    if (jerkResult.anyJerkDetected && jerkResult.eventType != null) {
      sessionProvider.recordJerkEvent(
        jerkResult.eventType!,
        jerkValue: jerkResult.steeringJerkValue ?? jerkResult.brakeJerkValue,
      );
    }

    // Update session provider
    sessionProvider.updateSensorData(
      speedKmh: processed.speedKmh,
      aLong: processed.displayALong,
      aLat: processed.displayALat,
      yawRate: processed.displayYawRate,
      estimatedGrade: gradePercent,
      gradeInSteadyState: gradeInSteadyState,
    );

    sessionProvider.updateTractionFractions(
      longFrac: tractionResult.longFrac,
      latFrac: tractionResult.latFrac,
      combinedFrac: tractionResult.combinedFrac,
    );

    // Update local state for UI
    if (mounted) {
      setState(() {
        _tractionResult = tractionResult;
        _stoppingResult = stoppingResult;
      });
    }
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _sensorService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SessionProvider, AppState>(
      builder: (context, sessionProvider, appState, child) {
        final settings = appState.settings;
        final isMetric = settings.isMetric;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Motion lock banner
                MotionLockBanner(isVisible: sessionProvider.isMoving),

                // Main content
                Expanded(
                  child: settings.viewMode == 'bars'
                      ? _buildTractionBarsView(sessionProvider, settings, isMetric)
                      : _buildStoppingDistanceView(sessionProvider, settings, isMetric),
                ),

                // Bottom bar with End Session button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GripCoachTheme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      onPressed: () => _endSession(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GripCoachTheme.errorRed,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text(
                        'End Session',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTractionBarsView(
    SessionProvider sessionProvider,
    SessionSettings settings,
    bool isMetric,
  ) {
    final isAccel = _tractionResult.longBar == BarDirection.accel;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header row: Speed and Grade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SpeedDisplay(
                speedKmh: sessionProvider.speedKmh,
                isMetric: isMetric,
                size: SpeedDisplaySize.medium,
              ),
              GradeDisplay(
                gradePercent: sessionProvider.estimatedGrade,
                isAutoGrade: settings.autoGrade,
                inSteadyState: sessionProvider.gradeInSteadyState,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Traction bars
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left bar
                LedBar(
                  fraction: _tractionResult.latFrac,
                  isActive: _tractionResult.latBar == BarDirection.left,
                  height: 280,
                  width: 50,
                ),

                // Center bar
                CenterBar(
                  accelFraction: _tractionResult.longFrac,
                  brakeFraction: _tractionResult.longFrac,
                  isAccelerating: isAccel,
                  height: 280,
                  width: 60,
                ),

                // Right bar
                LedBar(
                  fraction: _tractionResult.latFrac,
                  isActive: _tractionResult.latBar == BarDirection.right,
                  height: 280,
                  width: 50,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Smoothness label
          SmoothnessLabel(isChoppy: sessionProvider.isChoppy),

          const SizedBox(height: 16),

          // Following distance
          FollowingDistanceCard(
            speedKmh: sessionProvider.speedKmh,
            roadCondition: settings.roadCondition,
            isMetric: isMetric,
          ),
        ],
      ),
    );
  }

  Widget _buildStoppingDistanceView(
    SessionProvider sessionProvider,
    SessionSettings settings,
    bool isMetric,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header row: Speed and Grade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SpeedDisplay(
                speedKmh: sessionProvider.speedKmh,
                isMetric: isMetric,
                size: SpeedDisplaySize.medium,
              ),
              GradeDisplay(
                gradePercent: sessionProvider.estimatedGrade,
                isAutoGrade: settings.autoGrade,
                inSteadyState: sessionProvider.gradeInSteadyState,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stopping distance display
          Expanded(
            child: Center(
              child: StoppingDistanceDisplay(
                result: _stoppingResult,
                isMetric: isMetric,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Following distance
          FollowingDistanceCard(
            speedKmh: sessionProvider.speedKmh,
            roadCondition: settings.roadCondition,
            isMetric: isMetric,
          ),
        ],
      ),
    );
  }

  void _endSession(BuildContext context) {
    final sessionProvider = context.read<SessionProvider>();
    final completedSession = sessionProvider.endSession();

    if (completedSession != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DebriefScreen(session: completedSession),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
