// test/fakes/fake_preferences_service.dart
import 'package:flutter_pegsolitaire/services/preferences_service.dart';

/// Implementación en memoria que simula SharedPreferences sin canales de plataforma.
class FakePreferencesService implements PreferencesService {
  bool _soundEnabled = true;
  int _bestRemainingPegs = 32;

  @override
  bool get isSoundEnabled => _soundEnabled;

  @override
  Future<bool> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    return true;
  }

  @override
  int get bestRemainingPegs => _bestRemainingPegs;

  @override
  Future<bool> checkAndSaveRecord(int remainingPegs) async {
    if (remainingPegs < _bestRemainingPegs) {
      _bestRemainingPegs = remainingPegs;
      return true;
    }
    return false;
  }

  @override
  // TODO: implement isVibrationEnabled
  bool get isVibrationEnabled => throw UnimplementedError();

  @override
  Future<bool> setVibrationEnabled(bool enabled) {
    // TODO: implement setVibrationEnabled
    throw UnimplementedError();
  }
}