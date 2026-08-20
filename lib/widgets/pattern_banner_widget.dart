import 'package:flutter/material.dart';
import '../battle/patterns.dart';

/// Banner Horizontal Pola-Pola Serangan Aktif Ronde Ini.
class PatternBannerWidget extends StatelessWidget {
  final List<BattlePattern> activePatterns;

  const PatternBannerWidget({super.key, required this.activePatterns});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activePatterns.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = activePatterns[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF222235),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Text(p.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      p.effectDescription,
                      style: const TextStyle(color: Colors.purpleAccent, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
