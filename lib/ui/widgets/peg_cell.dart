import 'package:flutter/material.dart';
import 'package:flutter_pegsolitaire/core/enums/cell_type.dart';


class PegCell extends StatelessWidget {
  final int row;
  final int col;
  final CellType cellType;
  final bool isSelected;
  final VoidCallback? onTap;

  const PegCell({
    super.key,
    required this.row,
    required this.col,
    required this.cellType,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    if (cellType == CellType.voidCell) {
      return const SizedBox.shrink();
    }


    final theme = Theme.of(context);

    // 2. GestureDetector DEBE envolver el contenedor visible
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.amberAccent : Colors.grey[600]!,
            width: isSelected ? 3.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Center(
          child: _buildPieceContent(theme),
        ),
      ),
    );
  }

  Widget _buildPieceContent(ThemeData theme) {
    if (cellType == CellType.occupiedPeg) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
      );
    } else if (cellType == CellType.emptyHole) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          shape: BoxShape.circle,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}