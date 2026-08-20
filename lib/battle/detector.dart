import '../core/board.dart';
import 'patterns.dart';

class PatternMatch {
  final BattlePattern pattern;
  final Set<({int r, int c})> matchedCells;
  final ({int r, int c}) anchor;

  PatternMatch({
    required this.pattern,
    required this.matchedCells,
    required this.anchor,
  });
}

/// Detektor Pola Serangan pada Papan Sudoku.
class PatternDetector {
  /// Deteksi seluruh pola yang aktif terbentuk dari sel user-filled.
  List<PatternMatch> detect(SudokuBoard board, List<BattlePattern> activePatterns) {
    final userFilled = _getUserFilledSet(board);
    final results = <PatternMatch>[];

    for (final pattern in activePatterns) {
      for (final translation in pattern.getAllTranslations(boardSize: 9)) {
        if (translation.every((cell) => userFilled.contains(cell))) {
          final anchorR = translation.map((e) => e.r).reduce((a, b) => a < b ? a : b);
          final anchorC = translation.map((e) => e.c).reduce((a, b) => a < b ? a : b);

          results.add(PatternMatch(
            pattern: pattern,
            matchedCells: translation,
            anchor: (r: anchorR, c: anchorC),
          ));
        }
      }
    }
    return results;
  }

  Set<({int r, int c})> _getUserFilledSet(SudokuBoard board) {
    final userFilled = <({int r, int c})>{};
    for (int r = 0; r < SudokuBoard.size; r++) {
      for (int c = 0; c < SudokuBoard.size; c++) {
        final cell = board.cells[r][c];
        if (!cell.isGiven && cell.value != 0 && cell.isValid) {
          userFilled.add((r: r, c: c));
        }
      }
    }
    return userFilled;
  }

  /// Deteksi pola baru yang belum pernah terpicu sebelumnya pada ronde berjalan.
  List<PatternMatch> detectNewPatterns(
    SudokuBoard board,
    List<BattlePattern> activePatterns,
    Set<String> alreadyTriggeredKeys,
  ) {
    final matches = detect(board, activePatterns);
    final newMatches = <PatternMatch>[];

    for (final match in matches) {
      final key = "${match.pattern.id}_${match.anchor.r}_${match.anchor.c}";
      if (!alreadyTriggeredKeys.contains(key)) {
        newMatches.add(match);
      }
    }
    return newMatches;
  }
}
