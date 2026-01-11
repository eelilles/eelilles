import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Application-wide state provider
class AppState extends ChangeNotifier {
  /// Current session settings
  SessionSettings _settings = const SessionSettings();
  SessionSettings get settings => _settings;

  /// Calibration data
  CalibrationData _calibration = CalibrationData.invalid();
  CalibrationData get calibration => _calibration;

  /// Whether calibration is complete
  bool get isCalibrated => _calibration.isValid;

  /// Tuning parameters (dev screen)
  TuningParams _tuningParams = TuningParams.defaults();
  TuningParams get tuningParams => _tuningParams;

  /// Whether dev mode is enabled
  bool _devModeEnabled = false;
  bool get devModeEnabled => _devModeEnabled;

  /// Dev mode tap counter
  int _devModeTapCount = 0;

  /// Whether the app has shown onboarding
  bool _hasShownOnboarding = false;
  bool get hasShownOnboarding => _hasShownOnboarding;

  // ============ Settings ============

  void setRoadCondition(String condition) {
    _settings = _settings.copyWith(roadCondition: condition);
    notifyListeners();
  }

  void setDriverLevel(String level) {
    _settings = _settings.copyWith(driverLevel: level);
    notifyListeners();
  }

  void setUnits(String units) {
    _settings = _settings.copyWith(units: units);
    notifyListeners();
  }

  void setGradePercent(double grade) {
    _settings = _settings.copyWith(gradePercent: grade);
    notifyListeners();
  }

  void setViewMode(String mode) {
    _settings = _settings.copyWith(viewMode: mode);
    notifyListeners();
  }

  void setAutoGrade(bool enabled) {
    _settings = _settings.copyWith(autoGrade: enabled);
    notifyListeners();
  }

  void updateSettings(SessionSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  // ============ Calibration ============

  void setCalibration(CalibrationData calibration) {
    _calibration = calibration;
    notifyListeners();
  }

  void clearCalibration() {
    _calibration = CalibrationData.invalid();
    notifyListeners();
  }

  // ============ Tuning ============

  void updateTuningParams(TuningParams params) {
    _tuningParams = params;
    notifyListeners();
  }

  void resetTuningParams() {
    _tuningParams = TuningParams.defaults();
    notifyListeners();
  }

  // ============ Dev Mode ============

  /// Handle tap on version label (7 taps to enable dev mode)
  void handleDevModeTap() {
    _devModeTapCount++;
    if (_devModeTapCount >= 7) {
      _devModeEnabled = true;
      _devModeTapCount = 0;
      notifyListeners();
    }
  }

  void disableDevMode() {
    _devModeEnabled = false;
    _devModeTapCount = 0;
    notifyListeners();
  }

  // ============ Onboarding ============

  void setOnboardingComplete() {
    _hasShownOnboarding = true;
    notifyListeners();
  }
}
