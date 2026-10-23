import 'package:flutter/material.dart';
import 'package:flutter_pegsolitaire/core/enums/cell_type.dart';
import 'package:flutter_pegsolitaire/models/board_position.dart';


class PegCell extends StatelessWidget {
  final BoardPosition position;
  final CellType cellType;
  final bool isSelected;
  final bool isTargetHint;
  final VoidCallback? onTap;

  const PegCell({
    super.key,
    required this.position,
    required this.cellType,
    this.isSelected = false,
    this.isTargetHint = false,
    this.onTap,
  });

  String _buildSemanticLabel() {
    final row = position.row + 1;
    final col = position.col + 1;
    final typeDesc = cellType == CellType.occupiedPeg ? 'Clavija ocupada' : 'Hueco vacío';
    if (isSelected) {
      return 'Fila $row, Columna $col, $typeDesc. Seleccionada actualmente. Toca para deseleccionar.';
    }
    if (isTargetHint) {
      return 'Fila $row, Columna $col, $typeDesc. Destino válido para saltar. Toca para mover la clavija aquí.';
    }
    return 'Fila $row, Columna $col, $typeDesc.';
  }

  @override
  Widget build(BuildContext context) {
    if (cellType == CellType.voidCell) {
      return const ExcludeSemantics(child: SizedBox.shrink());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cellBaseColor = isDark ? const Color(0xFF2A2622) : const Color(0xFFD7CCC8);
    final borderColor = isSelected
        ? Colors.amberAccent
        : isTargetHint
            ? (isDark ? Colors.tealAccent : Colors.teal)
            : (isDark ? const Color(0xFF3E3832) : const Color(0xFFA1887F));

    return Semantics(
      label: _buildSemanticLabel(),
      button: true,
      enabled: cellType != CellType.voidCell,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isTargetHint
              ? (isDark ? Colors.teal.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.25))
              : cellBaseColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: isSelected || isTargetHint ? 3.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.7),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : isTargetHint
                  ? [
                      BoxShadow(
                        color: (isDark ? Colors.tealAccent : Colors.teal).withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                        blurRadius: 3,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
        ),
        child: Center(
          child: _buildPieceContent(theme, isDark),
        ),
      ),
    ),);
  }

  Widget _buildPieceContent(ThemeData theme, bool isDark) {
    if (cellType == CellType.occupiedPeg) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 0.85,
            colors: isDark
                ? [
                    const Color(0xFF64B5F6),
                    theme.colorScheme.primary,
                    const Color(0xFF0D47A1),
                  ]
                : [
                    const Color(0xFF42A5F5),
                    theme.colorScheme.primary,
                    const Color(0xFF0D47A1),
                  ],
            stops: const [0.0, 0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
      );
    } else if (cellType == CellType.emptyHole) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: isDark
                ? [const Color(0xFF0A0908), const Color(0xFF1E1B18)]
                : [const Color(0xFF2E241E), const Color(0xFF4E342E)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.15),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}