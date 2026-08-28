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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        border: Border.all(color: Colors.grey[600]!, width: 1.5),
      ),
      child: Center(
        child: cellType == CellType.occupiedPeg
            ? Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Color.fromARGB(255, 26, 18, 18), size: 20)
                    : Image.asset('assets/icons/ghost.png'),
              )
            : cellType == CellType.emptyHole
                ? Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                : null, // No dibuja nada para voidCell
      ),
    );
  }
}