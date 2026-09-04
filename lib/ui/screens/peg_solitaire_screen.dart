import 'package:flutter/material.dart';
import 'package:flutter_pegsolitaire/core/enums/cell_type.dart';
import 'package:flutter_pegsolitaire/models/game_record.dart';
import 'package:flutter_pegsolitaire/ui/screens/rules_screen.dart';
import 'package:flutter_pegsolitaire/ui/widgets/peg_cell.dart';
import 'package:logger/logger.dart';

class PegSolitaireScreen extends StatefulWidget {
 PegSolitaireScreen({super.key});

  static const int gridSize = 7;
  static const int totalCells = gridSize * gridSize; 
  @override
  State<PegSolitaireScreen> createState() => _PegSolitaireScreenState();
}

class _PegSolitaireScreenState extends State<PegSolitaireScreen> {
 // 49 casillas
  int rowSelected = 0;

  int colSelected = 0;

  Logger _logger = Logger();

  GameRecord _lastGameRecord = GameRecord(
    id: '%FDFDFE#4434FDD#',
    date: DateTime.now(),
    remainingPegs: 33,
    totalMoves: 0,
    durationSeconds: 349,
    isVictory: false,
  );

  /// Determina el tipo de celda según sus coordenadas matriciales (row, col)
  CellType _getCellType(int row, int col) {
    // Esquinas 2x2 no jugables en el tablero inglés estándar
    final bool isCorner = (row < 2 || row > 4) && (col < 2 || col > 4);
    if (isCorner) {
      return CellType.voidCell;
    }
    // El resto de las 32 posiciones inician ocupadas
    return CellType.occupiedPeg;
  }

 void _handleCellTapped(int row, int col, CellType type) {
  _logger.i('Celda tocada en: $row, $col | Tipo: $type');
    if (type == CellType.voidCell) return;

    setState(() {
      if (rowSelected == row && colSelected == col) {
        _logger.d('Deseleccionada celda en: ${rowSelected}, ${colSelected}');
      } else {
        rowSelected = row;
        colSelected = col;
        _logger.d('Seleccionada celda para acción: ${row}, ${col}  | Tipo: $type');
      }
    });
  }

 Widget _gameBoard() {
   _logger.i("Construyendo el tablero de juego");
   return Center(
     child: Padding(
       padding: const EdgeInsets.all(8.0),
       child: AspectRatio(
         aspectRatio: 1.0, // Cuadrado perfecto
         child: GridView.builder(
           physics: const NeverScrollableScrollPhysics(), // Bloquea el scroll
           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: PegSolitaireScreen.gridSize, // 7 columnas
             crossAxisSpacing: 2.0,
             mainAxisSpacing: 2.0,
           ),
           itemCount: PegSolitaireScreen.totalCells, // 7x7 = 49 celdas
           itemBuilder: (context, index) {
             // Convertir el índice en coordenadas matriciales
             final int row = index ~/ PegSolitaireScreen.gridSize;
             final int col = index % PegSolitaireScreen.gridSize;
             final CellType cellType = _getCellType(row, col);
             // Evaluación booleana reactiva para la celda actual
             final bool isSelected = (rowSelected == row && colSelected == col);
             
             return PegCell(
                row: row,
                col: col,
                cellType: cellType,
                isSelected: isSelected, // Pasa el estado reactivo
                onTap: () => _handleCellTapped(row, col, cellType),
              );
           },
         ),
       ),
     ),
   );
 }

@override
Widget build(BuildContext context) {

  _logger.i("Último registro de juego: $_lastGameRecord.remainingPegs piezas restantes ${_lastGameRecord.remainingPegs}, ${_lastGameRecord.durationSeconds} segundos jugados");

  return Scaffold(
    appBar: AppBar(title: const Text('Solitario'),
    actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Reglas del juego',
            onPressed: () {
              _logger.i('Navegando a RulesScreen desde PegSolitaireScreen');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RulesScreen()),
              );
            },
          ),
        ],),
    
    body: SafeArea( // Protege la UI de los bordes del dispositivo
       child: Column( // Apila el marcador arriba y el tablero abajo
         children: [
           // Área de Status
           Container(
             height: 60,
             color: Colors.grey[300],
             child: const Center(
               child: Text('STATUS: 349 segundos | Piezas restantes: 33',
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
               ),
             ),
           ),
           const Divider(height: 1),
           // Área de Juego
           Expanded( // Expande el tablero para llenar la pantalla
             child: _gameBoard(),
           ),
         ],
       ),
     ),
   );
 }
}
