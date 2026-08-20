import 'dart:math';
import 'board.dart';
import 'validator.dart';

/// Solver & AI Hint System untuk Sudoku.
class SudokuSolver {
  /// Mencari sel terbaik untuk Hint menggunakan Most Constrained Variable (MCV).
  ({int r, int c})? getHintCell(SudokuBoard board) {
    ({int r, int c})? bestCell;
    int minCandidates = 10;

    for (int r = 0; r < SudokuBoard.size; r++) {
      for (int c = 0; c < SudokuBoard.size; c++) {
        if (board.cells[r][c].value == 0) {
          final candidates = board.getCandidates(r, c);
          if (candidates.length < minCandidates) {
            minCandidates = candidates.length;
            bestCell = (r: r, c: c);
            if (minCandidates == 1) return bestCell; // Naked single langsung return
          }
        }
      }
    }
    return bestCell;
  }

  /// Dapatkan hint untuk seluruh sel kosong pada kolom tertentu (Bonus Hint Column).
  List<({int r, int c, int val})> getHintsForColumn(SudokuBoard board, int col) {
    final hints = <({int r, int c, int val})>[];
    final sol = board.solution;

    for (int r = 0; r < SudokuBoard.size; r++) {
      if (board.cells[r][col].value == 0) {
        if (sol != null) {
          hints.add((r: r, c: col, val: sol[r][col]));
        } else {
          final cands = board.getCandidates(r, col);
          if (cands.isNotEmpty) {
            hints.add((r: r, c: col, val: cands.first));
          }
        }
      }
    }
    return hints;
  }

  /// Pilih satu kolom secara acak yang masih memiliki sel kosong untuk dijadikan Hint Column.
  int? pickRandomHintColumn(SudokuBoard board) {
    final eligibleCols = <int>[];
    for (int c = 0; c < SudokuBoard.size; c++) {
      for (int r = 0; r < SudokuBoard.size; r++) {
        if (board.cells[r][c].value == 0) {
          eligibleCols.add(c);
          break;
        }
      }
    }
    if (eligibleCols.isEmpty) return null;
    return eligibleCols[Random().nextInt(eligibleCols.length)];
  }
}
