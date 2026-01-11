import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Service for local storage of sessions and settings
class StorageService {
  static const String _settingsKey = 'last_settings';
  static const String _sessionsIndexKey = 'sessions_index';
  static const String _onboardingKey = 'has_shown_onboarding';

  /// Get app documents directory
  Future<Directory> get _sessionDir async {
    final dir = await getApplicationDocumentsDirectory();
    final sessionDir = Directory('${dir.path}/sessions');
    if (!await sessionDir.exists()) {
      await sessionDir.create(recursive: true);
    }
    return sessionDir;
  }

  // ============ Settings ============

  /// Save last used settings
  Future<void> saveSettings(SessionSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  /// Load last used settings
  Future<SessionSettings?> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_settingsKey);
      if (json != null) {
        return SessionSettings.fromJson(jsonDecode(json));
      }
    } catch (e) {
      // Return null on error
    }
    return null;
  }

  // ============ Onboarding ============

  /// Check if onboarding has been shown
  Future<bool> hasShownOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// Mark onboarding as shown
  Future<void> setOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // ============ Sessions ============

  /// Save a completed session
  Future<void> saveSession(SessionData session) async {
    try {
      final dir = await _sessionDir;
      final file = File('${dir.path}/${session.id}.json');
      await file.writeAsString(jsonEncode(session.toJson()));

      // Update index
      await _addToSessionIndex(session.id, session.startTime);
    } catch (e) {
      // Log error but don't throw
      print('Error saving session: $e');
    }
  }

  /// Load a session by ID
  Future<SessionData?> loadSession(String id) async {
    try {
      final dir = await _sessionDir;
      final file = File('${dir.path}/$id.json');
      if (await file.exists()) {
        final json = await file.readAsString();
        return SessionData.fromJson(jsonDecode(json));
      }
    } catch (e) {
      // Return null on error
    }
    return null;
  }

  /// Get list of all session IDs with dates (most recent first)
  Future<List<(String, DateTime)>> getSessionList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final indexJson = prefs.getString(_sessionsIndexKey);
      if (indexJson == null) return [];

      final index = jsonDecode(indexJson) as List<dynamic>;
      final sessions = <(String, DateTime)>[];

      for (final item in index) {
        final map = item as Map<String, dynamic>;
        sessions.add((
          map['id'] as String,
          DateTime.parse(map['date'] as String),
        ));
      }

      // Sort by date, most recent first
      sessions.sort((a, b) => b.$2.compareTo(a.$2));
      return sessions;
    } catch (e) {
      return [];
    }
  }

  /// Get the most recent session
  Future<SessionData?> getLastSession() async {
    final sessions = await getSessionList();
    if (sessions.isEmpty) return null;
    return loadSession(sessions.first.$1);
  }

  /// Delete a session
  Future<void> deleteSession(String id) async {
    try {
      final dir = await _sessionDir;
      final file = File('${dir.path}/$id.json');
      if (await file.exists()) {
        await file.delete();
      }
      await _removeFromSessionIndex(id);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Clear all sessions
  Future<void> clearAllSessions() async {
    try {
      final dir = await _sessionDir;
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionsIndexKey);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _addToSessionIndex(String id, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final indexJson = prefs.getString(_sessionsIndexKey);
      List<dynamic> index = [];

      if (indexJson != null) {
        index = jsonDecode(indexJson) as List<dynamic>;
      }

      // Add new entry
      index.add({
        'id': id,
        'date': date.toIso8601String(),
      });

      // Keep only last 50 sessions
      if (index.length > 50) {
        final toRemove = index.sublist(0, index.length - 50);
        index = index.sublist(index.length - 50);

        // Delete old session files
        final dir = await _sessionDir;
        for (final item in toRemove) {
          final oldId = (item as Map<String, dynamic>)['id'] as String;
          final file = File('${dir.path}/$oldId.json');
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      await prefs.setString(_sessionsIndexKey, jsonEncode(index));
    } catch (e) {
      // Ignore index errors
    }
  }

  Future<void> _removeFromSessionIndex(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final indexJson = prefs.getString(_sessionsIndexKey);
      if (indexJson == null) return;

      final index = jsonDecode(indexJson) as List<dynamic>;
      index.removeWhere(
        (item) => (item as Map<String, dynamic>)['id'] == id,
      );

      await prefs.setString(_sessionsIndexKey, jsonEncode(index));
    } catch (e) {
      // Ignore errors
    }
  }
}
