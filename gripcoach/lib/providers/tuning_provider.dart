import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tuning_params.dart';

/// Provider for tuning parameters (dev screen)
class TuningProvider extends ChangeNotifier {
  static const String _storageKey = 'tuning_params';

  TuningParams _params = TuningParams.defaults();
  TuningParams get params => _params;

  /// Load tuning params from storage
  Future<void> loadParams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json != null) {
        _params = TuningParams.fromJson(jsonDecode(json));
        notifyListeners();
      }
    } catch (e) {
      // Use defaults on error
      _params = TuningParams.defaults();
    }
  }

  /// Save tuning params to storage
  Future<void> saveParams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_params.toJson()));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Update a single parameter
  void updateParam(TuningParams Function(TuningParams) updater) {
    _params = updater(_params);
    saveParams();
    notifyListeners();
  }

  /// Reset to defaults
  void resetToDefaults() {
    _params = TuningParams.defaults();
    saveParams();
    notifyListeners();
  }

  // ============ Convenience Setters ============

  void setDisplayTau(double value) {
    _params = _params.copyWith(displayTauS: value);
    saveParams();
    notifyListeners();
  }

  void setEventTau(double value) {
    _params = _params.copyWith(eventTauS: value);
    saveParams();
    notifyListeners();
  }

  void setJerkYawThreshold(double value) {
    _params = _params.copyWith(jerkYawThreshold: value);
    saveParams();
    notifyListeners();
  }

  void setJerkLatThreshold(double value) {
    _params = _params.copyWith(jerkLatThreshold: value);
    saveParams();
    notifyListeners();
  }

  void setJerkLongThreshold(double value) {
    _params = _params.copyWith(jerkLongThreshold: value);
    saveParams();
    notifyListeners();
  }

  void setDeltaYawRateThreshold(double value) {
    _params = _params.copyWith(deltaYawRateThreshold: value);
    saveParams();
    notifyListeners();
  }

  void setMotionLockSpeed(double value) {
    _params = _params.copyWith(motionLockSpeedKmh: value);
    saveParams();
    notifyListeners();
  }

  void setMotionUnlockSpeed(double value) {
    _params = _params.copyWith(motionUnlockSpeedKmh: value);
    saveParams();
    notifyListeners();
  }

  void setMotionUnlockDuration(double value) {
    _params = _params.copyWith(motionUnlockDurationS: value);
    saveParams();
    notifyListeners();
  }

  void setGreenThreshold(double value) {
    _params = _params.copyWith(greenThreshold: value);
    saveParams();
    notifyListeners();
  }

  void setYellowThreshold(double value) {
    _params = _params.copyWith(yellowThreshold: value);
    saveParams();
    notifyListeners();
  }

  void setGradeTau(double value) {
    _params = _params.copyWith(gradeTauS: value);
    saveParams();
    notifyListeners();
  }

  void setRoadSensitivity(String road, double value) {
    final newSensitivity = Map<String, double>.from(_params.roadSensitivity);
    newSensitivity[road] = value;
    _params = _params.copyWith(roadSensitivity: newSensitivity);
    saveParams();
    notifyListeners();
  }
}
