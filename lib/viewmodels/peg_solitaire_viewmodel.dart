// lib/viewmodels/peg_solitaire_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_pegsolitaire/models/board_position.dart';
import 'package:logger/logger.dart';
import '../core/enums/cell_type.dart';


/// ViewModel que encapsula las reglas de negocio, la FSM y el estado del Peg Solitaire.
class PegSolitaireViewModel extends ChangeNotifier {
  static const int gridSize = 7;
  Logger logger = Logger();

  // Estado interno matricial y contadores
  late List<List<CellType>> _board;
  BoardPosition? _selectedPosition;
  int _remainingPegs = 0;
  int _moveCount = 0;
  bool _isGameOver = false;
  bool _isVictory = false;

  // Getters inmutables expuestos hacia la UI
  List<List<CellType>> get board => _board;
  BoardPosition? get selectedPosition => _selectedPosition;
  int get remainingPegs => _remainingPegs;
  int get moveCount => _moveCount;
  bool get isGameOver => _isGameOver;
  bool get isVictory => _isVictory;

  PegSolitaireViewModel() {
    initializeBoard();
  }

  /// Inicializa el Tablero Inglés Estándar (33 casillas, centro desocupado).
  void initializeBoard() {
    _board = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        // Esquinas no jugables (bloques 2x2 en las cuatro esquinas)
        if ((row < 2 || row > 4) && (col < 2 || col > 4)) {
          return CellType.voidCell;
        }
        // Centro estándar desocupado (3, 3)
        if (row == 3 && col == 3) {
          return CellType.emptyHole;
        }
        return CellType.occupiedPeg;
      });
    });

    _selectedPosition = null;
    _remainingPegs = 32;
    _moveCount = 0;
    _isGameOver = false;
    _isVictory = false;

    notifyListeners();
  }

  /// Retorna el tipo de celda en una coordenada cartesiana segura.
  CellType getCellType(int row, int col) {
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
      return CellType.voidCell;
    }
    return _board[row][col];
  }

  bool isCellSelected(BoardPosition pos) {
    return _selectedPosition == pos;
  }

  // lib/viewmodels/peg_solitaire_viewmodel.dart (Continuación)

  /// Procesa la pulsación de una celda gestionando la transición de estados de la FSM.
  void onCellTapped(BoardPosition pos) {
    if (_isGameOver) {
      return;
    }

    final CellType tappedType = _board[pos.row][pos.col];
    if (tappedType == CellType.voidCell) return;

    // ESTADO 0: IDLE (No hay celda origen seleccionada)
    if (_selectedPosition == null) {
      if (tappedType == CellType.occupiedPeg) {
        _selectedPosition = pos;
        notifyListeners();
      }
      return;
    }



    // ESTADO 1: SOURCE_SELECTED (Existe una clavija origen activa)
    final BoardPosition origin = _selectedPosition!;

    // Transición 1.1: Pulsar sobre la misma casilla -> Deselección (Toggle)
    if (origin == pos) {
      _selectedPosition = null;
      notifyListeners();
      return;
    }

    // Transición 1.2: Pulsar sobre otra clavija propia -> Alternar selección
    if (tappedType == CellType.occupiedPeg) {
      _selectedPosition = pos;
      notifyListeners();
      return;
    }

    // Transición 1.3: Pulsar sobre un hueco vacío -> Evaluar salto y captura
    if (tappedType == CellType.emptyHole) {
      if (_isValidMove(origin, pos)) {
        _executeMove(origin, pos);
        _selectedPosition = null; // Regreso automático a IDLE tras el salto
        _evaluateGameTermination();
        notifyListeners();
      } else {
        logger.w('Reglas: Intento de salto inválido rechazado desde $origin hacia $pos');
      }
    }
  }


  /// Valida formalmente el salto ortogonal, el destino desocupado y la clavija intermedia.
  bool _isValidMove(BoardPosition from, BoardPosition to) {
    final int rowDelta = (from.row - to.row).abs();
    final int colDelta = (from.col - to.col).abs();

    // 1. Debe ser un salto ortogonal estricto de distancia 2
    final bool isOrthogonalTwoStep =
        (rowDelta == 2 && colDelta == 0) || (rowDelta == 0 && colDelta == 2);
    if (!isOrthogonalTwoStep) return false;

    // 2. El destino debe ser un hueco vacío
    if (_board[to.row][to.col] != CellType.emptyHole) return false;

    // 3. La celda intermedia debe contener una clavija para ser capturada
    final int midRow = (from.row + to.row) ~/ 2;
    final int midCol = (from.col + to.col) ~/ 2;
    if (_board[midRow][midCol] != CellType.occupiedPeg) return false;

    return true;
  }

  /// Ejecuta la mutación atómica del tablero matricial y actualiza métricas.
  void _executeMove(BoardPosition from, BoardPosition to) {
    final int midRow = (from.row + to.row) ~/ 2;
    final int midCol = (from.col + to.col) ~/ 2;

    _board[from.row][from.col] = CellType.emptyHole;     // Origen queda vacío
    _board[midRow][midCol] = CellType.emptyHole;         // Clavija intermedia es removida
    _board[to.row][to.col] = CellType.occupiedPeg;       // Destino recibe la clavija

    _remainingPegs--;
    _moveCount++;

    logger.i('Salto ejecutado con éxito: $from -> $to | Clavijas restantes: $_remainingPegs');
  }

  /// Evalúa las condiciones de término de la partida (Victoria o Stalemate).
  void _evaluateGameTermination() {
    // Condición de Victoria: Queda exactamente 1 clavija en el tablero
    if (_remainingPegs == 1) {
      _isGameOver = true;
      _isVictory = true;
      logger.i('¡VICTORIA! Partida completada en $_moveCount movimientos.');
      return;
    }

    // Condición de Estancamiento (Stalemate): No quedan saltos ortogonales válidos
    if (!_hasValidMovesRemaining()) {
      _isGameOver = true;
      _isVictory = false;
      logger.w('STALEMATE: Fin de juego por bloqueo. No existen movimientos válidos.');
    }
  }

  /// Algoritmo exhaustivo de detección de estancamiento sobre las 33 casillas jugables.
  bool _hasValidMovesRemaining() {
    const List<List<int>> directions = [
      [-2, 0], // Arriba
      [2, 0],  // Abajo
      [0, -2], // Izquierda
      [0, 2],  // Derecha
    ];

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_board[r][c] == CellType.occupiedPeg) {
          final from = BoardPosition(r, c);

          for (final dir in directions) {
            final int targetRow = r + dir[0];
            final int targetCol = c + dir[1];

            // Validar que el salto potencial no desborde los límites de la matriz
            if (targetRow >= 0 && targetRow < gridSize &&
                targetCol >= 0 && targetCol < gridSize) {
              final to = BoardPosition(targetRow, targetCol);
              if (_board[targetRow][targetCol] != CellType.voidCell &&
                  _isValidMove(from, to)) {
                return true; // Existe al menos un movimiento válido en el tablero
              }
            }
          }
        }
      }
    }
    return false;
  }

}