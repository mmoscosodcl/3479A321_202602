import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pegsolitaire/core/enums/cell_type.dart';
import 'package:flutter_pegsolitaire/services/screenshot_service.dart';
import 'package:flutter_pegsolitaire/services/shake_detector_service.dart';
import 'package:flutter_pegsolitaire/ui/screens/rules_screen.dart';
import 'package:flutter_pegsolitaire/ui/widgets/peg_cell.dart';
import 'package:flutter_pegsolitaire/viewmodels/peg_solitaire_viewmodel.dart';
import 'package:flutter_pegsolitaire/models/board_position.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pegsolitaire/core/utils/app_logger.dart';

class PegSolitaireScreen extends StatefulWidget {
  const PegSolitaireScreen({super.key});

  @override
  State<PegSolitaireScreen> createState() => _PegSolitaireScreenState();
}

class _PegSolitaireScreenState extends State<PegSolitaireScreen> {
  ShakeDetectorService? _shakeDetector;
  final GlobalKey _boardBoundaryKey = GlobalKey();
  

  @override
  void initState() {
    super.initState();
    // Inicialización del detector de agitación
    _shakeDetector = ShakeDetectorService(
      onShake: _handleShakeEvent,
    );
    _shakeDetector?.startListening();
  }

  void _handleShakeEvent() {
    final vm = context.read<PegSolitaireViewModel>();

    // REGLA DE NEGOCIO: Solo actuar si la partida ha terminado
    if (vm.isGameOver) {
      AppLogger.info('Shake validado: Partida finalizada. Reiniciando tablero automáticamente.');
      vm.initializeBoard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Tablero reiniciado por movimiento físico!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      AppLogger.debug('Shake ignorado: La partida se encuentra activa.');
    }
  }

  @override
  void dispose() {
    // Liberación estricta para evitar fugas de memoria al salir de la pantalla
    _shakeDetector?.dispose();
    super.dispose();
  }
  
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              vm.isVictory
                  ? '¡VICTORIA PERFECTA! Has dejado exactamente una clavija.'
                  : 'JUEGO TERMINADO: No quedan movimientos válidos disponibles.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Compartir'),
            onPressed: () async {
              await _shareMatchResult(vm);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoardContainer(BuildContext context, PegSolitaireViewModel vm) {
    return RepaintBoundary(
      key: _boardBoundaryKey,
      child: _gameBoard(context, vm),
    );
}

void _handleCellTapped(BuildContext context, BoardPosition pos, PegSolitaireViewModel vm) {
    // 1. FILTRO DE DOMINIO: Si la celda es inválida (fuera del tablero inglés), descartar
    if (vm.getCellType(pos) == CellType.voidCell) {
      return;
    }

    AppLogger.debug('Celda tocada: $pos | Tipo: ${vm.getCellType(pos)} | Estado de selección: ${vm.isCellSelected(pos)}, Vibración y sonido activados.');
    HapticFeedback.heavyImpact(); // Retroalimentación háptica para interacción táctil
    
    vm.onCellTapped(pos);
  }

  Widget _gameBoard(BuildContext context, PegSolitaireViewModel vm) {
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
             final CellType cellType = vm.getCellType(position);

             
             return PegCell(
                position: position,
                cellType: cellType,
                isSelected: vm.isCellSelected(position), // Pasa el estado reactivo
                onTap: () => _handleCellTapped(context, position, vm),
              );
           },
         ),
       ),
     ),
   );
 }

// Despacho de evidencia visual mediante Share:
  Future<void> _shareMatchResult(PegSolitaireViewModel vm) async {
    HapticFeedback.mediumImpact();
    final imagePath = await ScreenshotService.captureWidgetToImage(_boardBoundaryKey);
    final String text = '¡Nuevo desafío en Peg Solitaire! Movimientos: ${vm.moveCount} | Piezas restantes: ${vm.remainingPegs}';

    if (imagePath != null) {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'Evidencia de Partida Peg Solitaire',
          title: '¡Mira mi partida en Peg Solitaire!',
          files: [XFile(imagePath)],
        ),
      );
    } else {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'Evidencia de Partida Peg Solitaire',
          title: '¡Mira mi partida en Peg Solitaire!'
        ),
      );
    }
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
              AppLogger.info('Navegando a RulesScreen desde PegSolitaireScreen');
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
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Compartir Resultado',
            onPressed: () => _shareMatchResult(vm),
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
             child: _buildGameBoardContainer(context,vm), // Construye el tablero de juego
           ),
           if (vm.isGameOver) _buildGameOverBanner(context, vm),
         ],
       ),
     ),
   );
 }
}
