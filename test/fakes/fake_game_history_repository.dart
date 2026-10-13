// test/fakes/fake_game_history_repository.dart
import 'package:flutter_pegsolitaire/models/game_record.dart';
import 'package:flutter_pegsolitaire/repositories/game_history_repository.dart';

/// Implementación en memoria que simula la persistencia sin acceder al sistema de archivos.
class FakeGameHistoryRepository implements IGameHistoryRepository {
  final List<GameRecord> _storage = [];

  List<GameRecord> get memoryRecords => List.unmodifiable(_storage);

  @override
  Future<List<GameRecord>> getHistory() async {
    return List.from(_storage);
  }

  @override
  Future<void> saveGame(GameRecord record) async {
    _storage.insert(0, record);
  }

  @override
  Future<void> clearHistory() async {
    _storage.clear();
  }
}