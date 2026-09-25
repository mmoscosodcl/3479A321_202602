import 'package:flutter/material.dart';
import 'package:flutter_pegsolitaire/core/enums/cell_type.dart';
import 'package:flutter_pegsolitaire/ui/screens/rules_screen.dart';
import 'package:flutter_pegsolitaire/ui/widgets/peg_cell.dart';
import 'package:flutter_pegsolitaire/viewmodels/peg_solitaire_viewmodel.dart';
import 'package:logger/logger.dart';
import 'package:flutter_pegsolitaire/models/board_position.dart';
import 'package:provider/provider.dart';

class PegSolitaireScreen extends StatelessWidget {
  PegSolitaireScreen({super.key});
  Logger _logger = Logger();
  
  Widget _buildScoreBoard(BuildContext context, PegSolitaireViewModel vm) {
    return Container(
      height: 65,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMetric(context, 'Piezas', '${vm.remainingPegs}', Icons.circle),
          _buildMetric(context, 'Movimientos', '${vm.moveCount}', Icons.swap_horiz_rounded),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }


  Widget _buildGameOverBanner(BuildContext context, PegSolitaireViewModel vm) {
    return Container(
      width: double.infinity,
      color: vm.isVictory ? Colors.green[800] : Colors.red[900],
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        vm.isVictory
            ? '¡VICTORIA PERFECTA! Has dejado exactamente una clavija.'
            : 'JUEGO TERMINADO: No quedan movimientos válidos disponibles.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

 Widget _gameBoard(BuildContext context, PegSolitaireViewModel vm) {
   _logger.i("Construyendo el tablero de juego");
   return Center(
     child: Padding(
       padding: const EdgeInsets.all(8.0),
       child: AspectRatio(
         aspectRatio: 1.0, // Cuadrado perfecto
         child: GridView.builder(
           physics: const NeverScrollableScrollPhysics(), // Bloquea el scroll
           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: PegSolitaireViewModel.gridSize, // 7 columnas
             crossAxisSpacing: 2.0,
             mainAxisSpacing: 2.0,
           ),
           itemCount: PegSolitaireViewModel.gridSize * PegSolitaireViewModel.gridSize, // 7x7 = 49 celdas
           itemBuilder: (context, index) {
             // Convertir el índice en coordenadas matriciales
             final int row = index ~/ PegSolitaireViewModel.gridSize;
             final int col = index % PegSolitaireViewModel.gridSize;
             final position = BoardPosition(row,col);
             final CellType cellType = vm.getCellType(row, col);

             
             return PegCell(
                position: position,
                cellType: cellType,
                isSelected: vm.isCellSelected(position), // Pasa el estado reactivo
                onTap: () => context.read<PegSolitaireViewModel>().onCellTapped(position),
              );
           },
         ),
       ),
     ),
   );
 }

@override
Widget build(BuildContext context) {
    final vm = context.watch<PegSolitaireViewModel>();

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
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reiniciar Tablero',
            onPressed: () => context.read<PegSolitaireViewModel>().initializeBoard(),
          ),
        ],),
    
    body: SafeArea( // Protege la UI de los bordes del dispositivo
       child: Column( // Apila el marcador arriba y el tablero abajo
         children: [
           // Área de Status
           _buildScoreBoard(context, vm),
           const Divider(height: 1),
           // Área de Juego
           Expanded( // Expande el tablero para llenar la pantalla
             child: _gameBoard(context,vm), // Construye el tablero de juego
           ),
           if (vm.isGameOver) _buildGameOverBanner(context, vm),
         ],
       ),
     ),
   );
 }
}
