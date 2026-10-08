// lib/services/preferences_service.dart
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PreferencesService {
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyBestScore = 'best_remaining_pegs';

  final SharedPreferences _prefs;

  final Logger _logger = Logger();

  PreferencesService(this._prefs);


  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // --- CONFIGURACION INICIAL
  bool get isSoundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;
  bool get isVibrationEnabled => _prefs.getBool(_keyVibrationEnabled) ?? true;
  int get bestRemainingPegs => _prefs.getInt(_keyBestScore) ?? 32;

  Future<bool> setSoundEnabled(bool enabled) async {
    _logger.i('PreferencesService: Sonido configurado en $enabled');
    return await _prefs.setBool(_keySoundEnabled, enabled);
  }

  Future<bool> setVibrationEnabled(bool enabled) async {
    _logger.i('PreferencesService: Vibración configurada en $enabled');
    return await _prefs.setBool(_keyVibrationEnabled, enabled);
  }

  Future<bool> checkAndSaveRecord(int remainingPegs) async {
    final currentBest = bestRemainingPegs;
    if (remainingPegs < currentBest) {
      _logger.i('¡NUEVO RÉCORD! Piezas restantes superadas: $remainingPegs (Anterior: $currentBest)');
      return await _prefs.setInt(_keyBestScore, remainingPegs);
    }
    return false;
  }
}