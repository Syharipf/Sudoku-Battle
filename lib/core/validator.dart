/// Validator Aturan Sudoku Standar.
class SudokuValidator {
  static const int size = 9;
  static const int boxSize = 3;

  /// Cek apakah angka [num] valid ditempatkan pada [grid] di posisi ([row], [col]).
  static bool isValidPlacement(List<List<int>> grid, int row, int col, int num) {
    // Cek baris
    for (int c = 0; c < size; c++) {
      if (c != col && grid[row][c] == num) return false;
    }

    // Cek kolom
    for (int r = 0; r < size; r++) {
      if (r != row && grid[r][col] == num) return false;
    }

    // Cek kotak 3x3
    final br = (row ~/ boxSize) * boxSize;
    final bc = (col ~/ boxSize) * boxSize;
    for (int r = br; r < br + boxSize; r++) {
      for (int c = bc; c < bc + boxSize; c++) {
        if ((r != row || c != col) && grid[r][c] == num) return false;
      }
    }

    return true;
  }

  /// Cek apakah papan telah selesai dan valid sepenuhnya.
  static bool isBoardCompleteAndValid(List<List<int>> grid) {
    final expected = {1, 2, 3, 4, 5, 6, 7, 8, 9};

    // Cek baris
    for (int r = 0; r < size; r++) {
      if (grid[r].toSet().length != size || grid[r].contains(0)) return false;
    }

    // Cek kolom
    for (int c = 0; c < size; c++) {
      final colSet = List.generate(size, (r) => grid[r][c]).toSet();
      if (colSet.length != size || colSet.contains(0)) return false;
    }

    // Cek box 3x3
    for (int br = 0; br < boxSize; br++) {
      for (int bc = 0; bc < boxSize; bc++) {
        final boxSet = <int>{};
        for (int r = br * boxSize; r < (br + 1) * boxSize; r++) {
          for (int c = bc * boxSize; c < (bc + 1) * boxSize; c++) {
            boxSet.add(grid[r][c]);
          }
        }
        if (boxSet.length != size || boxSet.contains(0)) return false;
      }
    }

    return true;
  }
}
