// test/fakes/fake_audio_service.dart
import 'package:flutter_pegsolitaire/services/audio_service.dart';

/// Doble de prueba en memoria que neutraliza los canales nativos de audio.
class FakeAudioService implements AudioService {
  int playSelectCount = 0;
  int playJumpCount = 0;
  int playGameOverCount = 0;

  @override
  Future<void> playSelect() async {
    playSelectCount++;
  }

  @override
  Future<void> playJump() async {
    playJumpCount++;
  }

  @override
  Future<void> playGameOver() async {
    playGameOverCount++;
  }

  @override
  void dispose() {}
}