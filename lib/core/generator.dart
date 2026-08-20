import 'dart:math';
import 'validator.dart';

/// Generator Puzzle Sudoku dengan jaminan solusi unik.
class PuzzleGenerator {
  static const Map<String, int> cellsToRemove = {
    'easy': 34,
    'medium': 44,
    'hard': 50,
    'expert': 56,
  };

  /// Generate pasangan (puzzle, solution).
  ({List<List<int>> puzzle, List<List<int>> solution}) generate({String difficulty = 'medium'}) {
    final solution = _generateFullBoard();
    final puzzle = _createPuzzle(solution, difficulty);
    return (puzzle: puzzle, solution: solution);
  }

  List<List<int>> _generateFullBoard() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(grid);
    return grid;
  }

  bool _fillBoard(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(Random());
          for (final num in numbers) {
            if (SudokuValidator.isValidPlacement(grid, r, c, num)) {
              grid[r][c] = num;
              if (_fillBoard(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  List<List<int>> _createPuzzle(List<List<int>> solution, String difficulty) {
    final puzzle = solution.map((row) => List<int>.from(row)).toList();
    final countToRemove = cellsToRemove[difficulty] ?? 44;

    final positions = <({int r, int c})>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add((r: r, c: c));
      }
    }
    positions.shuffle(Random());

    int removed = 0;
    for (final pos in positions) {
      if (removed >= countToRemove) break;

      final backup = puzzle[pos.r][pos.c];
      puzzle[pos.r][pos.c] = 0;

      if (_countSolutions(puzzle) == 1) {
        removed++;
      } else {
        puzzle[pos.r][pos.c] = backup;
      }
    }

    return puzzle;
  }

  int _countSolutions(List<List<int>> grid, {int limit = 2}) {
    final workGrid = grid.map((row) => List<int>.from(row)).toList();
    int count = 0;

    bool backtrack(List<List<int>> g) {
      if (count >= limit) return true;

      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (g[r][c] == 0) {
            for (int num = 1; num <= 9; num++) {
              if (SudokuValidator.isValidPlacement(g, r, c, num)) {
                g[r][c] = num;
                backtrack(g);
                if (count >= limit) {
                  g[r][c] = 0;
                  return true;
                }
                g[r][c] = 0;
              }
            }
            return false;
          }
        }
      }
      count++;
      return false;
    }

    backtrack(workGrid);
    return count;
  }
}
