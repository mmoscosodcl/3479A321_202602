// lib/repositories/game_history_repository.dart
import '../models/game_record.dart';

/// Contrato abstracto que desacopla la lógica de negocio de la tecnología de persistencia.
abstract class IGameHistoryRepository {
  Future<List<GameRecord>> getHistory();
  Future<void> saveGame(GameRecord record);
  Future<void> clearHistory();
}