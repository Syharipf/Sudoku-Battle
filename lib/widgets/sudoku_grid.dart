import 'package:flutter/material.dart';
import '../core/board.dart';

/// Interactive Touch 9x9 Sudoku Grid untuk Layar Mobile.
class SudokuGridWidget extends StatelessWidget {
  final SudokuBoard board;
  final ({int r, int c})? selectedCell;
  final Function(int r, int c) onCellTapped;
  final Set<({int r, int c})>? highlightedPatternCells;

  const SudokuGridWidget({
    super.key,
    required this.board,
    required this.selectedCell,
    required this.onCellTapped,
    this.highlightedPatternCells,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF14141F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.8), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.15),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: List.generate(9, (r) {
            return Expanded(
              child: Row(
                children: List.generate(9, (c) {
                  return Expanded(
                    child: _buildCell(r, c),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    final cell = board.cells[r][c];
    final isSelected = selectedCell?.r == r && selectedCell?.c == c;
    final isSameRowOrCol = selectedCell != null && (selectedCell!.r == r || selectedCell!.c == c);
    final isSameBox = selectedCell != null &&
        (selectedCell!.r ~/ 3 == r ~/ 3) &&
        (selectedCell!.c ~/ 3 == c ~/ 3);
    final isSameNumber = selectedCell != null &&
        board.cells[selectedCell!.r][selectedCell!.c].value != 0 &&
        board.cells[selectedCell!.r][selectedCell!.c].value == cell.value;
    final isHintCol = board.hintColumn == c;
    final isPatternCell = highlightedPatternCells?.contains((r: r, c: c)) ?? false;

    // Background color priority
    Color bgColor = Colors.transparent;
    if (isSelected) {
      bgColor = Colors.cyanAccent.withOpacity(0.4);
    } else if (isPatternCell) {
      bgColor = Colors.purpleAccent.withOpacity(0.35);
    } else if (isSameNumber) {
      bgColor = Colors.cyanAccent.withOpacity(0.25);
    } else if (isHintCol && cell.value == 0) {
      bgColor = Colors.amberAccent.withOpacity(0.2);
    } else if (isSameRowOrCol || isSameBox) {
      bgColor = Colors.white.withOpacity(0.04);
    }

    // Text color & style
    Color textColor = Colors.white;
    FontWeight fontWeight = FontWeight.normal;

    if (cell.isGiven) {
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
    } else if (!cell.isValid) {
      textColor = Colors.redAccent;
      fontWeight = FontWeight.bold;
    } else if (cell.value != 0) {
      textColor = Colors.greenAccent;
      fontWeight = FontWeight.bold;
    }

    // 3x3 Border Styling
    final borderTop = r % 3 == 0 && r != 0 ? const BorderSide(color: Colors.white38, width: 1.5) : const BorderSide(color: Colors.white12, width: 0.5);
    final borderLeft = c % 3 == 0 && c != 0 ? const BorderSide(color: Colors.white38, width: 1.5) : const BorderSide(color: Colors.white12, width: 0.5);

    return GestureDetector(
      onTap: () => onCellTapped(r, c),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: borderTop,
            left: borderLeft,
            bottom: const BorderSide(color: Colors.white12, width: 0.5),
            right: const BorderSide(color: Colors.white12, width: 0.5),
          ),
        ),
        alignment: Alignment.center,
        child: cell.value != 0
            ? Text(
                "${cell.value}",
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: fontWeight,
                ),
              )
            : cell.notes.isNotEmpty
                ? _buildNotesGrid(cell.notes)
                : null,
      ),
    );
  }

  Widget _buildNotesGrid(List<int> notes) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(2),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (i) {
        final num = i + 1;
        return Center(
          child: Text(
            notes.contains(num) ? "$num" : "",
            style: const TextStyle(color: Colors.amberAccent, fontSize: 8),
          ),
        );
      }),
    );
  }
}
