import 'package:flutter/material.dart';
import '../core/board.dart';

/// Mini Preview Papan Lawan Real-time di Layar PvP Mobile.
class MiniOpponentGridWidget extends StatelessWidget {
  final SudokuBoard board;

  const MiniOpponentGridWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        children: List.generate(9, (r) {
          return Expanded(
            child: Row(
              children: List.generate(9, (c) {
                final cell = board.cells[r][c];
                Color cellColor = Colors.transparent;

                if (cell.isGiven) {
                  cellColor = Colors.white24;
                } else if (!cell.isValid) {
                  cellColor = Colors.redAccent;
                } else if (cell.value != 0) {
                  cellColor = Colors.greenAccent;
                }

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(0.5),
                    color: cellColor,
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
