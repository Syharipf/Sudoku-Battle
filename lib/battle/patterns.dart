import 'dart:math';

enum EffectType { attack, heal, multiplier, shield, ultimate, scramble }

class PatternEffect {
  final EffectType type;
  final double value;

  const PatternEffect(this.type, this.value);
}

/// Definition of a single Sudoku Battle Pattern.
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
          parts.add("Deal -${e.value.toInt()} HP");
          break;
        case EffectType.heal:
          parts.add("Restore +${e.value.toInt()} HP");
          break;
        case EffectType.multiplier:
          parts.add("DMG ×${e.value.toStringAsFixed(1)}");
          break;
        case EffectType.shield:
          parts.add("Activate Shield (Block 1 Attack)");
          break;
        case EffectType.ultimate:
          parts.add("ULTIMATE -${e.value.toInt()} HP");
          break;
        case EffectType.scramble:
          parts.add("Scramble Opponent + -${e.value.toInt()} HP");
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

/// Full pool of 11 Battle Patterns.
const List<BattlePattern> patternPool = [
  BattlePattern(
    id: "cross",
    name: "Cross (+)",
    description: "Deal 15 DMG to opponent with a plus shape.",
    icon: "✚",
    cells: [(r: 0, c: 1), (r: 1, c: 0), (r: 1, c: 1), (r: 1, c: 2), (r: 2, c: 1)],
    effects: [PatternEffect(EffectType.attack, 15)],
  ),
  BattlePattern(
    id: "mini_heart",
    name: "Mini Heart",
    description: "Restore +10 HP with a heart shape.",
    icon: "♥",
    cells: [(r: 0, c: 0), (r: 0, c: 2), (r: 1, c: 0), (r: 1, c: 1), (r: 1, c: 2), (r: 2, c: 1)],
    effects: [PatternEffect(EffectType.heal, 10)],
  ),
  BattlePattern(
    id: "l_shape",
    name: "L-Shape",
    description: "Deal 10 DMG with an L-corner.",
    icon: "⌐",
    cells: [(r: 0, c: 0), (r: 1, c: 0), (r: 2, c: 0), (r: 2, c: 1)],
    effects: [PatternEffect(EffectType.attack, 10)],
  ),
  BattlePattern(
    id: "diagonal",
    name: "Diagonal",
    description: "Apply ×1.5 DMG Multiplier to next attack.",
    icon: "↗",
    cells: [(r: 0, c: 0), (r: 1, c: 1), (r: 2, c: 2)],
    effects: [PatternEffect(EffectType.multiplier, 1.5)],
  ),
  BattlePattern(
    id: "box_2x2",
    name: "Box 2×2",
    description: "Activate shield to block next incoming attack.",
    icon: "🛡️",
    cells: [(r: 0, c: 0), (r: 0, c: 1), (r: 1, c: 0), (r: 1, c: 1)],
    effects: [PatternEffect(EffectType.shield, 0)],
  ),
  BattlePattern(
    id: "zigzag",
    name: "Zigzag",
    description: "Deal 12 DMG with a lightning zigzag.",
    icon: "⚡",
    cells: [(r: 0, c: 1), (r: 1, c: 0), (r: 2, c: 1)],
    effects: [PatternEffect(EffectType.attack, 12)],
  ),
  BattlePattern(
    id: "row_streak",
    name: "Row Streak",
    description: "Deal 18 DMG with 4 consecutive row cells.",
    icon: "➡",
    cells: [(r: 0, c: 0), (r: 0, c: 1), (r: 0, c: 2), (r: 0, c: 3)],
    effects: [PatternEffect(EffectType.attack, 18)],
  ),
  BattlePattern(
    id: "col_streak",
    name: "Column Streak",
    description: "Deal 18 DMG with 4 consecutive column cells.",
    icon: "⬇",
    cells: [(r: 0, c: 0), (r: 1, c: 0), (r: 2, c: 0), (r: 3, c: 0)],
    effects: [PatternEffect(EffectType.attack, 18)],
  ),
  BattlePattern(
    id: "t_shape",
    name: "T-Shape",
    description: "Deal 12 DMG & restore +5 HP.",
    icon: "🗡️",
    cells: [(r: 0, c: 0), (r: 0, c: 1), (r: 0, c: 2), (r: 1, c: 1)],
    effects: [PatternEffect(EffectType.attack, 12), PatternEffect(EffectType.heal, 5)],
  ),
  BattlePattern(
    id: "x_wing",
    name: "X-Wing",
    description: "Deal 20 Heavy DMG with 4 corner cells.",
    icon: "✖",
    cells: [(r: 0, c: 0), (r: 0, c: 2), (r: 2, c: 0), (r: 2, c: 2)],
    effects: [PatternEffect(EffectType.attack, 20)],
  ),
  BattlePattern(
    id: "column_scramble",
    name: "Column Chaos",
    description: "Scramble opponent column & deal 7 DMG.",
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
