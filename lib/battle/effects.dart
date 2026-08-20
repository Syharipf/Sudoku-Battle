import 'player.dart';
import 'patterns.dart';
import 'detector.dart';

class EffectResult {
  final BattlePattern pattern;
  final Player caster;
  final Player target;
  final int damageDealt;
  final int healAmount;
  final double multiplierApplied;
  final bool shieldActivated;
  final bool blocked;
  final bool scrambleTriggered;
  final String message;

  EffectResult({
    required this.pattern,
    required this.caster,
    required this.target,
    required this.damageDealt,
    required this.healAmount,
    required this.multiplierApplied,
    required this.shieldActivated,
    required this.blocked,
    required this.scrambleTriggered,
    required this.message,
  });
}

/// Engine Pengaplikasian Efek Pola ke Caster dan Opponent.
class EffectEngine {
  EffectResult applyMatch(PatternMatch match, Player caster, Player opponent) {
    final pattern = match.pattern;
    int totalDamage = 0;
    int totalHeal = 0;
    double multiplierSet = 1.0;
    bool shieldActivated = false;
    bool blocked = false;
    bool scrambleTriggered = false;

    // 1. MULTIPLIER
    for (final effect in pattern.effects) {
      if (effect.type == EffectType.multiplier) {
        multiplierSet = effect.value;
        caster.setMultiplier(effect.value);
      }
    }

    // 2. ATTACK & ULTIMATE
    for (final effect in pattern.effects) {
      if (effect.type == EffectType.attack || effect.type == EffectType.ultimate) {
        final mult = caster.consumeMultiplier();
        final rawDamage = (effect.value * mult).toInt();
        final actual = opponent.takeDamage(rawDamage);

        if (actual == 0 && rawDamage > 0) {
          blocked = true;
        }
        totalDamage += actual;
      }
    }

    // 3. HEAL
    for (final effect in pattern.effects) {
      if (effect.type == EffectType.heal) {
        final actualHeal = caster.heal(effect.value.toInt());
        totalHeal += actualHeal;
      }
    }

    // 4. SHIELD
    for (final effect in pattern.effects) {
      if (effect.type == EffectType.shield) {
        caster.activateShield();
        shieldActivated = true;
      }
    }

    // 5. SCRAMBLE
    for (final effect in pattern.effects) {
      if (effect.type == EffectType.scramble) {
        final dmg = effect.value.toInt();
        final actual = opponent.takeDamage(dmg);
        if (actual == 0 && dmg > 0) {
          blocked = true;
        } else {
          scrambleTriggered = true;
        }
        totalDamage += actual;
      }
    }

    if (totalDamage > 0) {
      caster.stats.totalDamageDealt += totalDamage;
      caster.stats.patternsTriggered++;
    }

    final message = _buildMessage(pattern, {
      'damage': totalDamage,
      'heal': totalHeal,
      'multiplier': multiplierSet,
      'shield': shieldActivated,
      'blocked': blocked,
      'scramble': scrambleTriggered,
    });

    return EffectResult(
      pattern: pattern,
      caster: caster,
      target: opponent,
      damageDealt: totalDamage,
      healAmount: totalHeal,
      multiplierApplied: multiplierSet,
      shieldActivated: shieldActivated,
      blocked: blocked,
      scrambleTriggered: scrambleTriggered,
      message: message,
    );
  }

  List<EffectResult> applyMatches(List<PatternMatch> matches, Player caster, Player opponent) {
    return matches.map((m) => applyMatch(m, caster, opponent)).toList();
  }

  String _buildMessage(BattlePattern pattern, Map<String, dynamic> data) {
    final parts = <String>[];
    if (data['blocked'] == true) {
      parts.add("attack blocked by opponent's Shield!");
    } else if ((data['damage'] as int) > 0) {
      parts.add("opponent -${data['damage']} HP");
    }

    if (data['scramble'] == true && data['blocked'] != true) {
      parts.add("opponent's column scrambled! 🔀");
    }

    if ((data['heal'] as int) > 0) {
      parts.add("restored +${data['heal']} HP");
    }

    if ((data['multiplier'] as double) > 1.0) {
      parts.add("multiplier ×${(data['multiplier'] as double).toStringAsFixed(1)} active");
    }

    if (data['shield'] == true) {
      parts.add("Shield activated 🛡️");
    }

    if (parts.isNotEmpty) {
      return "${pattern.icon} [${pattern.name}] ${parts.join(', ')}";
    }
    return "${pattern.icon} [${pattern.name}] triggered!";
  }
}
