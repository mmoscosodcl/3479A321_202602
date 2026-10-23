import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_pegsolitaire/core/utils/app_logger.dart';


class AudioService {
  static final AudioService instance = AudioService._internal();
  late final AudioPlayer _player;


  bool _isInitialized = false;

  AudioService._internal() {
    _player = AudioPlayer();
    _configurePlayer();
  }

  Future<void> _configurePlayer() async {
    try {
      // Optimización: Modo de baja latencia para respuestas acústicas inmediatas
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      _isInitialized = true;
      AppLogger.info('AudioService inicializado en modo Low Latency');
    } catch (e) {
      AppLogger.error('Fallo en la inicialización del AudioService: $e');
    }
  }

  bool isSoundEnabled = true;

  Future<void> playSelect() async {
    if (!_isInitialized || !isSoundEnabled) return;
    try {
      await _player.play(AssetSource('audios/selection.mp3'));
    } catch (e) {
      AppLogger.error('No se pudo reproducir selection.mp3: $e');
    }
  }

  Future<void> playJump() async {
    if (!_isInitialized || !isSoundEnabled) return;
    try {
      await _player.play(AssetSource('audios/jump.mp3'));
      AppLogger.info('Reproduciendo jump.mp3 con éxito');
    } catch (e) {
      AppLogger.error('No se pudo reproducir jump.mp3: $e');
    }
  }

  Future<void> playGameOver() async {
    if (!_isInitialized || !isSoundEnabled) return;
    try {
      await _player.play(AssetSource('audios/defeat.mp3'));
    } catch (e) {
      AppLogger.error('No se pudo reproducir defeat.mp3: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}