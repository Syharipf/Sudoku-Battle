import 'dart:math';

/// Status pemain dalam battle.
enum PlayerStatus { alive, dead }

/// Data statistik kumulatif pemain.
class PlayerStats {
  int roundsPlayed = 0;
  int roundsWon = 0;
  int patternsTriggered = 0;
  int totalDamageDealt = 0;
  int totalDamageTaken = 0;
  int totalHeal = 0;
  int errorsMade = 0;
  int penaltyCount = 0;
  int hintsUsed = 0;
}

/// Model Pemain dengan sistem HP, Shield, Multiplier, dan Penalti.
class Player {
  static const int maxHp = 100;
  static const int penaltyDamage = 1;

  final String name;
  final int playerId;
  int hp;
  PlayerStatus status;
  final PlayerStats stats;

  double damageMultiplier = 1.0;
  bool isShielded = false;

  Player({
    required this.name,
    required this.playerId,
  })  : hp = maxHp,
        status = PlayerStatus.alive,
        stats = PlayerStats();

  double get hpPercentage => (hp / maxHp).clamp(0.0, 1.0);

  /// Terima damage dari serangan lawan (bisa diblok shield).
  int takeDamage(int amount) {
    if (isShielded) {
      isShielded = false;
      return 0; // Serangan sukses diblokir
    }

    final actual = min(amount, hp);
    hp -= actual;
    stats.totalDamageTaken += actual;

    if (hp <= 0) {
      hp = 0;
      status = PlayerStatus.dead;
    }
    return actual;
  }

  /// Penalti -1 HP karena salah mengisi sel (tidak bisa diblok shield).
  int takePenalty() {
    final actual = min(penaltyDamage, hp);
    hp -= actual;
    stats.penaltyCount++;
    stats.errorsMade++;
    stats.totalDamageTaken += actual;

    if (hp <= 0) {
      hp = 0;
      status = PlayerStatus.dead;
    }
    return actual;
  }

  /// Pulihkan HP (tidak melebihi maxHp).
  int heal(int amount) {
    final actual = min(amount, maxHp - hp);
    hp += actual;
    stats.totalHeal += actual;
    return actual;
  }

  void activateShield() {
    isShielded = true;
  }

  void setMultiplier(double mult) {
    damageMultiplier *= mult;
  }

  double consumeMultiplier() {
    final m = damageMultiplier;
    damageMultiplier = 1.0;
    return m;
  }

  bool get isAlive => status == PlayerStatus.alive;

  void resetForNewGame() {
    hp = maxHp;
    status = PlayerStatus.alive;
    damageMultiplier = 1.0;
    isShielded = false;
  }

  void resetRoundState() {
    damageMultiplier = 1.0;
    isShielded = false;
  }
}
