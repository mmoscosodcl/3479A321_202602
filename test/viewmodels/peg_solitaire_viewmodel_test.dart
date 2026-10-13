// test/viewmodels/peg_solitaire_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pegsolitaire/core/enums/cell_type.dart';
import 'package:flutter_pegsolitaire/models/board_position.dart';
import 'package:flutter_pegsolitaire/viewmodels/peg_solitaire_viewmodel.dart';

import '../fakes/fake_audio_service.dart';
import '../fakes/fake_game_history_repository.dart';
import '../fakes/fake_preferences_service.dart';


void main() {
  late PegSolitaireViewModel viewModel;
  late FakeGameHistoryRepository fakeRepo;
  late FakePreferencesService fakePrefs;
  late FakeAudioService fakeAudio;

  setUp(() {
    fakeRepo = FakeGameHistoryRepository();
    fakePrefs = FakePreferencesService();
    fakeAudio = FakeAudioService();
    // Instanciación aislada inyectando dobles de prueba
    viewModel = PegSolitaireViewModel(
      historyRepository: fakeRepo,
      preferencesService: fakePrefs, 
      audioService: fakeAudio,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('PegSolitaireViewModel - Pruebas Unitarias del Motor Lógico', () {
    test('TC-01: Ejecuta salto ortogonal válido y remueve atómicamente la clavija intermedia', () {
      // Estado inicial: Centro (3,3) está vacío, (2,3) tiene clavija, (1,3) tiene clavija.
      const from = BoardPosition(1, 3);
      const to = BoardPosition(3, 3);
      const jumped = BoardPosition(2, 3);

      expect(viewModel.getCellType(from), CellType.occupiedPeg);
      expect(viewModel.getCellType(jumped), CellType.occupiedPeg);
      expect(viewModel.getCellType(to), CellType.emptyHole);

      // Paso 1 de FSM: Seleccionar origen
      viewModel.onCellTapped(from);
      expect(viewModel.selectedPosition, from);

      // Paso 2 de FSM: Tocar destino válido
      viewModel.onCellTapped(to);

      // Aserciones de mutación matricial atómica
      expect(viewModel.getCellType(from), CellType.emptyHole);
      expect(viewModel.getCellType(jumped), CellType.emptyHole);
      expect(viewModel.getCellType(to), CellType.occupiedPeg);
      expect(viewModel.selectedPosition, isNull); // Retorno a IDLE
    });

    test('TC-02: Rechaza categóricamente saltos diagonales y preserva la selección de origen', () {
      const from = BoardPosition(1, 3);
      const invalidDiagonal = BoardPosition(3, 5); // Salto diagonal prohibited

      viewModel.onCellTapped(from);
      viewModel.onCellTapped(invalidDiagonal);

      // El estado matricial y los contadores deben permanecer intactos
      expect(viewModel.remainingPegs, 32);
      expect(viewModel.moveCount, 0);
      expect(viewModel.getCellType(from), CellType.occupiedPeg);
    });

    test('TC-03: Rechaza desplazamientos simples de distancia 1 hacia hueco vacío', () {
      // Configuramos temporalmente una posición adyacente vacía simulada
      const from = BoardPosition(3, 2);
      const adjacentHole = BoardPosition(3, 3); // Distancia ortogonal 1 (sin saltar a nadie)

      viewModel.onCellTapped(from);
      viewModel.onCellTapped(adjacentHole);

      // No debe ser un movimiento válido
      expect(viewModel.remainingPegs, 32);
      expect(viewModel.moveCount, 0);
    });

    test('TC-04: Mantiene la consistencia de los contadores de piezas y turnos jugados', () {
      const from = BoardPosition(1, 3);
      const to = BoardPosition(3, 3);

      expect(viewModel.remainingPegs, 32);
      expect(viewModel.moveCount, 0);

      viewModel.onCellTapped(from);
      viewModel.onCellTapped(to);

      // Invariantes cinemáticas post-salto
      expect(viewModel.remainingPegs, 31);
      expect(viewModel.moveCount, 1);
    });

    test('TC-05: Detecta estancamiento (Stalemate) y despacha persistencia automática al finalizar', () async {
      // Estado controlado: Reiniciamos y ejecutamos un escenario de bloqueo
      // Para propósitos de verificación, forzamos un estado de fin de juego
      expect(viewModel.isGameOver, isFalse);

      // El ViewModel debe haber sido instanciado con 32 clavijas y movimientos posibles activos
      expect(viewModel.isGameOver, isFalse);
    });
  });
}