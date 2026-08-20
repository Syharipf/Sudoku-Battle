import 'package:flutter/material.dart';
import '../battle/player.dart';

/// Widget HP Bar Animasi dengan Shield & Multiplier Badge.
class HpBarWidget extends StatelessWidget {
  final Player player;
  final bool isOpponent;

  const HpBarWidget({
    super.key,
    required this.player,
    this.isOpponent = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = player.hpPercentage;
    Color barColor = Colors.greenAccent;
    if (pct < 0.3) {
      barColor = Colors.redAccent;
    } else if (pct < 0.6) {
      barColor = Colors.amberAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpponent ? Colors.redAccent.withOpacity(0.5) : Colors.cyanAccent.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isOpponent ? Icons.smart_toy_outlined : Icons.person_outline,
                    size: 16,
                    color: isOpponent ? Colors.redAccent : Colors.cyanAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    player.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isOpponent ? Colors.redAccent : Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (player.isShielded)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blueAccent, width: 1),
                      ),
                      child: const Text("🛡️ SHIELD", style: TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    ),
                  if (player.damageMultiplier > 1.0)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.purpleAccent, width: 1),
                      ),
                      child: Text("⚡ x${player.damageMultiplier.toStringAsFixed(1)}", style: const TextStyle(fontSize: 10, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                    ),
                  Text(
                    "${player.hp} / ${Player.maxHp}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: barColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
