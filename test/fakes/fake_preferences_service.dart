import 'package:flutter/foundation.dart';
import 'package:flutter_pegsolitaire/services/preferences_service.dart';

/// Implementación en memoria que simula SharedPreferences sin canales de plataforma.
class FakePreferencesService extends ChangeNotifier implements PreferencesService {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _shakeResetEnabled = true;
  String _themeModeName = 'system';
  int _bestRemainingPegs = 32;
  String? _activeSnapshot;

  @override
  bool get isSoundEnabled => _soundEnabled;

  @override
  bool get isVibrationEnabled => _vibrationEnabled;

  @override
  bool get isShakeResetEnabled => _shakeResetEnabled;

  @override
  String get themeModeName => _themeModeName;

  @override
  int get bestRemainingPegs => _bestRemainingPegs;

  @override
  bool get hasActiveGame => _activeSnapshot != null;

  @override
  String? get activeGameSnapshot => _activeSnapshot;

  @override
  Future<bool> saveActiveGameSnapshot(String jsonString) async {
    _activeSnapshot = jsonString;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> clearActiveGameSnapshot() async {
    _activeSnapshot = null;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> setShakeResetEnabled(bool enabled) async {
    _shakeResetEnabled = enabled;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> setThemeModeName(String mode) async {
    _themeModeName = mode;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> checkAndSaveRecord(int remainingPegs) async {
    if (remainingPegs < _bestRemainingPegs) {
      _bestRemainingPegs = remainingPegs;
      notifyListeners();
      return true;
    }
    return false;
  }
}