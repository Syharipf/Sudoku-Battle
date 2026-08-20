import 'dart:math';

enum EffectType { attack, heal, multiplier, shield, ultimate, scramble }

class PatternEffect {
  final EffectType type;
  final double value;

  const PatternEffect(this.type, this.value);
}

/// Definisi Satu Pola Serangan Sudoku Battle.
class BattlePattern {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<({int r, int c})> cells; // Relative offsets from anchor
  final List<PatternEffect> effects;

  const BattlePattern({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.cells,
    required this.effects,
  });

  ({int rows, int cols}) get boundingBox {
    if (cells.isEmpty) return (rows: 0, cols: 0);
    int maxR = cells.map((e) => e.r).reduce(max);
    int maxC = cells.map((e) => e.c).reduce(max);
    return (rows: maxR + 1, cols: maxC + 1);
  }

  String get effectDescription {
    final parts = <String>[];
    for (final e in effects) {
      switch (e.type) {
        case EffectType.attack:
          parts.add("Serang lawan -${e.value.toInt()} HP");
          break;
        case EffectType.heal:
          parts.add("Pulihkan +${e.value.toInt()} HP");
          break;
        case EffectType.multiplier:
          parts.add("Damage ×${e.value.toStringAsFixed(1)}");
          break;
        case EffectType.shield:
          parts.add("Aktifkan Shield (Blok 1 Serangan)");
          break;
        case EffectType.ultimate:
          parts.add("ULTIMATE -${e.value.toInt()} HP");
          break;
        case EffectType.scramble:
          parts.add("Acak Kolom Lawan + -${e.value.toInt()} HP");
          break;
      }
    }
    return parts.join(" | ");
  }

  List<Set<({int r, int c})>> getAllTranslations({int boardSize = 9}) {
    final bb = boundingBox;
    final results = <Set<({int r, int c})>>[];

    for (int anchorR = 0; anchorR <= boardSize - bb.rows; anchorR++) {
      for (int anchorC = 0; anchorC <= boardSize - bb.cols; anchorC++) {
        final absolutePos = cells.map((cell) => (r: anchorR + cell.r, c: anchorC + cell.c)).toSet();
        results.add(absolutePos);
      }
    }
    return results;
  }
}

/// Pool 11 Pola Serangan Lengkap.
const List<BattlePattern> patternPool = [
  BattlePattern(
    id: "cross",
    name: "Cross (+)",
    description: "Serang lawan -15 HP dengan bentuk plus.",
    icon: "✚",
    cells: [(r: 0, c: 1), (r: 1, c: 0), (r: 1, c: 1), (r: 1, c: 2), (r: 2, c: 1)],
    effects: [PatternEffect(EffectType.attack, 15)],
  ),
  BattlePattern(
    id: "mini_heart",
    name: "Mini Heart",
    description: "Pulihkan +10 HP dengan bentuk hati.",
    icon: "♥",
    cells: [(r: 0, c: 0), (r: 0, c: 2), (r: 1, c: 0), (r: 1, c: 1), (r: 1, c: 2), (r: 2, c: 1)],
    effects: [PatternEffect(EffectType.heal, 10)],
  ),
  BattlePattern(
    id: "l_shape",
    name: "L-Shape",
    description: "Serang lawan -10 HP dengan sudut L.",
    icon: "⌐",
    cells: [(r: 0, c: 0), (r: 1, c: 0), (r: 2, c: 0), (r: 2, c: 1)],
    effects: [PatternEffect(EffectType.attack, 10)],
  ),
  BattlePattern(
    id: "diagonal",
    name: "Diagonal",
    description: "Damage multiplier ×1.5 untuk serangan berikutnya.",
    icon: "↗",
    cells: [(r: 0, c: 0), (r: 1, c: 1), (r: 2, c: 2)],
    effects: [PatternEffect(EffectType.multiplier, 1.5)],
  ),
  BattlePattern(
    id: "box_2x2",
    name: "Box 2×2",
    description: "Aktifkan shield pemblokir 1 serangan.",
    icon: "🛡️",
    cells: [(r: 0, c: 0), (r: 0, c: 1), (r: 1, c: 0), (r: 1, c: 1)],
    effects: [PatternEffect(EffectType.shield, 0)],
  ),
  BattlePattern(
    id: "zigzag",
    name: "Zigzag",
    description: "Serang lawan -12 HP dengan pola zigzag.",
    icon: "⚡",
    cells: [(r: 0, c: 1), (r: 1, c: 0), (r: 2, c: 1)],
    effects: [PatternEffect(EffectType.attack, 12)],
  ),
  BattlePattern(
    id: "row_streak",
    name: "Row Streak",
    description: "Serang lawan -18 HP dengan 4 sel baris beruntun.",
    icon: "➡",
    cells: [(r: 0, c: 0), (r: 0, c: 1), (r: 0, c: 2), (r: 0, c: 3)],
    effects: [PatternEffect(EffectType.attack, 18)],
  ),
  BattlePattern(
    id: "col_streak",
    name: "Column Streak",
    description: "Serang lawan -18 HP dengan 4 sel kolom beruntun.",
    icon: "⬇",
    cells: [(r: 0, c: 0), (r: 1, c: 0), (r: 2, c: 0), (r: 3, c: 0)],
    effects: [PatternEffect(EffectType.attack, 18)],
  ),
  BattlePattern(
    id: "t_shape",
    name: "T-Shape",
    description: "Serang -12 HP & pulihkan +5 HP.",
    icon: "🗡️",
    cells: [(r: 0, c: 0), (r: 0, c: 1), (r: 0, c: 2), (r: 1, c: 1)],
    effects: [PatternEffect(EffectType.attack, 12), PatternEffect(EffectType.heal, 5)],
  ),
  BattlePattern(
    id: "x_wing",
    name: "X-Wing",
    description: "Serang lawan -20 HP dengan 4 sudut persegi 3x3.",
    icon: "✖",
    cells: [(r: 0, c: 0), (r: 0, c: 2), (r: 2, c: 0), (r: 2, c: 2)],
    effects: [PatternEffect(EffectType.attack, 20)],
  ),
  BattlePattern(
    id: "column_scramble",
    name: "Column Chaos",
    description: "Acak kolom lawan + serang -7 HP.",
    icon: "🔀",
    cells: [(r: 0, c: 0), (r: 1, c: 0), (r: 2, c: 0)],
    effects: [PatternEffect(EffectType.scramble, 7)],
  ),
];

List<BattlePattern> getRandomPatterns(int count, {Random? random}) {
  final rng = random ?? Random();
  final list = List<BattlePattern>.from(patternPool)..shuffle(rng);
  return list.take(count).toList();
}
