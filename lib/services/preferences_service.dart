import 'package:flutter/foundation.dart';
import 'package:flutter_pegsolitaire/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyShakeResetEnabled = 'shake_reset_enabled';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyBestScore = 'best_remaining_pegs';

  static const String _keyActiveGameState = 'active_game_snapshot';

  bool get hasActiveGame => _prefs.containsKey(_keyActiveGameState);

  String? get activeGameSnapshot => _prefs.getString(_keyActiveGameState);

  Future<bool> saveActiveGameSnapshot(String jsonString) async {
    final result = await _prefs.setString(_keyActiveGameState, jsonString);
    notifyListeners();
    return result;
  }

  Future<bool> clearActiveGameSnapshot() async {
    final result = await _prefs.remove(_keyActiveGameState);
    notifyListeners();
    return result;
  }

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // --- CONFIGURACION DE USUARIO
  bool get isSoundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;
  bool get isVibrationEnabled => _prefs.getBool(_keyVibrationEnabled) ?? true;
  bool get isShakeResetEnabled => _prefs.getBool(_keyShakeResetEnabled) ?? true;
  String get themeModeName => _prefs.getString(_keyThemeMode) ?? 'system';
  int get bestRemainingPegs => _prefs.getInt(_keyBestScore) ?? 32;

  Future<bool> setSoundEnabled(bool enabled) async {
    AppLogger.info('PreferencesService: Sonido configurado en $enabled');
    final result = await _prefs.setBool(_keySoundEnabled, enabled);
    notifyListeners();
    return result;
  }

  Future<bool> setVibrationEnabled(bool enabled) async {
    AppLogger.info('PreferencesService: Vibración configurada en $enabled');
    final result = await _prefs.setBool(_keyVibrationEnabled, enabled);
    notifyListeners();
    return result;
  }

  Future<bool> setShakeResetEnabled(bool enabled) async {
    AppLogger.info('PreferencesService: Agitar para reiniciar configurado en $enabled');
    final result = await _prefs.setBool(_keyShakeResetEnabled, enabled);
    notifyListeners();
    return result;
  }

  Future<bool> setThemeModeName(String mode) async {
    AppLogger.info('PreferencesService: Tema configurado en $mode');
    final result = await _prefs.setString(_keyThemeMode, mode);
    notifyListeners();
    return result;
  }

  Future<bool> checkAndSaveRecord(int remainingPegs) async {
    final currentBest = bestRemainingPegs;
    if (remainingPegs < currentBest) {
      AppLogger.info('¡NUEVO RÉCORD! Piezas restantes superadas: $remainingPegs (Anterior: $currentBest)');
      final result = await _prefs.setInt(_keyBestScore, remainingPegs);
      notifyListeners();
      return result;
    }
    return false;
  }
}