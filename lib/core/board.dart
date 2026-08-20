import 'dart:math';

/// Representasi satu sel pada papan Sudoku.
class Cell {
  int value;
  final bool isGiven;
  bool isValid;
  bool isHighlighted;
  List<int> notes; // Catatan pensil kecil

  Cell({
    this.value = 0,
    this.isGiven = false,
    this.isValid = true,
    this.isHighlighted = false,
    List<int>? notes,
  }) : notes = notes ?? [];

  Cell copy() {
    return Cell(
      value: value,
      isGiven: isGiven,
      isValid: isValid,
      isHighlighted: isHighlighted,
      notes: List<int>.from(notes),
    );
  }
}

/// Representasi Papan Sudoku 9x9 dengan dukungan Game Mechanics (Hint Column, Scramble, Validasi).
class SudokuBoard {
  static const int size = 9;
  static const int boxSize = 3;

  late List<List<Cell>> cells;
  List<List<int>>? _solution;
  int? hintColumn; // Kolom yang sedang aktif sebagai bonus hint

  SudokuBoard() {
    cells = List.generate(
      size,
      (_) => List.generate(size, (_) => Cell()),
    );
  }

  /// Memuat puzzle & solusi awal.
  void loadPuzzle(List<List<int>> puzzle, List<List<int>> solution) {
    _solution = solution.map((row) => List<int>.from(row)).toList();
    hintColumn = null;
    cells = List.generate(
      size,
      (r) => List.generate(
        size,
        (c) => Cell(
          value: puzzle[r][c],
          isGiven: puzzle[r][c] != 0,
          isValid: true,
        ),
      ),
    );
  }

  /// Mengisi nilai pada sel (row, col). Mengembalikan true jika benar.
  bool setValue(int row, int col, int val) {
    final cell = cells[row][col];
    if (cell.isGiven) return false;

    cell.value = val;
    cell.notes.clear();

    if (val == 0) {
      cell.isValid = true;
      return true;
    }

    if (_solution != null) {
      cell.isValid = (_solution![row][col] == val);
    } else {
      cell.isValid = true;
    }
    return cell.isValid;
  }

  /// Mengosongkan isi sel.
  void clearCell(int row, int col) {
    final cell = cells[row][col];
    if (!cell.isGiven) {
      cell.value = 0;
      cell.isValid = true;
      cell.notes.clear();
    }
  }

  /// Mengacak posisi angka yang diisi user pada suatu kolom (Efek Column Scramble).
  void scrambleColumnUserCells(int col) {
    final userRows = <int>[];
    for (int r = 0; r < size; r++) {
      if (!cells[r][col].isGiven && cells[r][col].value != 0) {
        userRows.add(r);
      }
    }

    if (userRows.length < 2) return;

    final values = userRows.map((r) => cells[r][col].value).toList();
    values.shuffle(Random());

    for (int i = 0; i < userRows.length; i++) {
      final r = userRows[i];
      final val = values[i];
      cells[r][col].value = val;
      if (_solution != null) {
        cells[r][col].isValid = (_solution![r][col] == val);
      }
    }
  }

  /// Cek apakah seluruh 81 sel terisi.
  bool isComplete() {
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (cells[r][c].value == 0) return false;
      }
    }
    return true;
  }

  /// Cek apakah seluruh sel terisi benar sesuai solusi.
  bool isCorrect() {
    if (_solution == null) return false;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (cells[r][c].value != _solution![r][c]) return false;
      }
    }
    return true;
  }

  /// Dapatkan kandidat angka valid untuk sel (row, col).
  List<int> getCandidates(int row, int col) {
    if (cells[row][col].value != 0) return [];
    final used = <int>{};

    for (int c = 0; c < size; c++) {
      if (cells[row][c].value != 0) used.add(cells[row][c].value);
    }
    for (int r = 0; r < size; r++) {
      if (cells[r][col].value != 0) used.add(cells[r][col].value);
    }

    final br = (row ~/ boxSize) * boxSize;
    final bc = (col ~/ boxSize) * boxSize;
    for (int r = br; r < br + boxSize; r++) {
      for (int c = bc; c < bc + boxSize; c++) {
        if (cells[r][c].value != 0) used.add(cells[r][c].value);
      }
    }

    final candidates = <int>[];
    for (int n = 1; n <= size; n++) {
      if (!used.contains(n)) candidates.add(n);
    }
    return candidates;
  }

  List<List<int>> toGrid() {
    return List.generate(
      size,
      (r) => List.generate(size, (c) => cells[r][c].value),
    );
  }

  List<List<int>>? get solution => _solution;
}
