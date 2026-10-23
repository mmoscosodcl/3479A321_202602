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

import 'package:flutter_pegsolitaire/services/preferences_service.dart';

class PegSolitaireScreen extends StatefulWidget {
  const PegSolitaireScreen({super.key});

  @override
  State<PegSolitaireScreen> createState() => _PegSolitaireScreenState();
}

class _PegSolitaireScreenState extends State<PegSolitaireScreen> {
  ShakeDetectorService? _shakeDetector;
  final GlobalKey _boardBoundaryKey = GlobalKey();
  bool _hasShownGameOverModal = false;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetectorService(
      onShake: _handleShakeEvent,
    );
    _shakeDetector?.startListening();
  }

  void _handleShakeEvent() {
    final prefs = context.read<PreferencesService>();
    if (!prefs.isShakeResetEnabled) {
      AppLogger.debug('Shake ignorado: La opción está deshabilitada en la configuración.');
      return;
    }

    final vm = context.read<PegSolitaireViewModel>();
    if (vm.isGameOver) {
      AppLogger.info('Shake validado: Partida finalizada. Reiniciando tablero.');
      _hasShownGameOverModal = false;
      vm.initializeBoard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Tablero reiniciado por agitación física!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      AppLogger.debug('Shake ignorado: La partida se encuentra activa.');
    }
  }

  @override
  void dispose() {
    _shakeDetector?.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit(BuildContext context, PegSolitaireViewModel vm) async {
    if (vm.moveCount == 0 || vm.isGameOver) {
      return true;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Deseas salir?'),
        content: const Text('Tienes una partida activa en progreso. Tu partida quedará guardada para continuar más tarde.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Seguir Jugando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await vm.saveActiveGameIfApplicable();
    }
    return shouldExit ?? false;
  }

  Future<void> _confirmResetBoard(BuildContext context, PegSolitaireViewModel vm) async {
    if (vm.moveCount == 0 || vm.isGameOver) {
      _hasShownGameOverModal = false;
      vm.initializeBoard();
      return;
    }

    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Reiniciar tablero?'),
        content: const Text('Se perderá el progreso de la partida actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      _hasShownGameOverModal = false;
      vm.initializeBoard();
    }
  }

  void _showGameOverModal(BuildContext context, PegSolitaireViewModel vm) {
    if (_hasShownGameOverModal) return;
    _hasShownGameOverModal = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (sheetContext) {
          final isVictory = vm.isVictory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  isVictory ? Icons.emoji_events_rounded : Icons.highlight_off_rounded,
                  color: isVictory ? Colors.amber[700] : Colors.red[800],
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  isVictory ? '¡VICTORIA PERFECTA!' : 'JUEGO TERMINADO',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isVictory
                    ? '¡Extraordinario! Lograste conservar una sola clavija en el tablero.'
                    : 'No quedan movimientos ortogonales posibles para saltar.',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  color: Theme.of(sheetContext).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Tiempo', vm.formattedTime),
                        _buildStatItem('Movimientos', '${vm.moveCount}'),
                        _buildStatItem('Restantes', '${vm.remainingPegs}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Jugar de nuevo'),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _hasShownGameOverModal = false;
                    vm.initializeBoard();
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Compartir resultado'),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await _shareMatchResult(vm);
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context);
                  },
                  child: const Text('Volver al Menú Principal'),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
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
          _buildMetric(context, 'Tiempo', vm.formattedTime, Icons.timer_outlined),
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
                  : 'JUEGO TERMINADO: No quedan movimientos válidos.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
            icon: const Icon(Icons.emoji_events_rounded, size: 18),
            label: const Text('Ver Detalle'),
            onPressed: () => _showGameOverModal(context, vm),
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
    if (vm.getCellType(pos) == CellType.voidCell) {
      return;
    }

    final prefs = context.read<PreferencesService>();
    if (prefs.isVibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
    
    vm.onCellTapped(pos);
  }

  Widget _gameBoard(BuildContext context, PegSolitaireViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: PegSolitaireViewModel.gridSize,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
            ),
            itemCount: PegSolitaireViewModel.gridSize * PegSolitaireViewModel.gridSize,
            itemBuilder: (context, index) {
              final int row = index ~/ PegSolitaireViewModel.gridSize;
              final int col = index % PegSolitaireViewModel.gridSize;
              final position = BoardPosition(row, col);
              final CellType cellType = vm.getCellType(position);

              return PegCell(
                position: position,
                cellType: cellType,
                isSelected: vm.isCellSelected(position),
                onTap: () => _handleCellTapped(context, position, vm),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _shareMatchResult(PegSolitaireViewModel vm) async {
    final prefs = context.read<PreferencesService>();
    if (prefs.isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
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
          title: '¡Mira mi partida en Peg Solitaire!',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PegSolitaireViewModel>();

    if (vm.isGameOver && !_hasShownGameOverModal) {
      _showGameOverModal(context, vm);
    }

    return PopScope(
      canPop: vm.moveCount == 0 || vm.isGameOver,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _confirmExit(context, vm);
        if (shouldExit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Solitario'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'Reglas del juego',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RulesScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reiniciar Tablero',
              onPressed: () => _confirmResetBoard(context, vm),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Configuración',
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Compartir Resultado',
              onPressed: () => _shareMatchResult(vm),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildScoreBoard(context, vm),
              const Divider(height: 1),
              Expanded(
                child: _buildGameBoardContainer(context, vm),
              ),
              if (vm.isGameOver) _buildGameOverBanner(context, vm),
            ],
          ),
        ),
      ),
    );
  }
}
