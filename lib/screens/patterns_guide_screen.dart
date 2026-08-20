import 'dart:math';
import 'package:flutter/material.dart';
import '../battle/patterns.dart';

/// Visual Guide and Interactive Matrix Preview for all 11 Battle Patterns.
class PatternsGuideScreen extends StatelessWidget {
  const PatternsGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        title: const Text("BATTLE PATTERNS GUIDE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: patternPool.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final p = patternPool[index];
          return _buildPatternCard(context, p);
        },
      ),
    );
  }

  Widget _buildPatternCard(BuildContext context, BattlePattern p) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPatternDetailDialog(context, p),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.35), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mini Visual Grid Matrix
              _buildMiniPatternGrid(p, cellSize: 18),
              const SizedBox(width: 16),

              // Description & Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${p.icon} ${p.name}",
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                          ),
                          child: Text(
                            "${p.cells.length} Tiles",
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amberAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "⚡ Effect: ${p.effectDescription}",
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.touch_app_outlined, color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPatternGrid(BattlePattern pattern, {double cellSize = 20}) {
    final bb = pattern.boundingBox;
    final rows = max(bb.rows, 3);
    final cols = max(bb.cols, 3);
    final cellSet = pattern.cells.map((c) => "${c.r},${c.c}").toSet();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF12121E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(rows, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cols, (c) {
              final isFilled = cellSet.contains("$r,$c");
              return Container(
                width: cellSize,
                height: cellSize,
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: isFilled ? const Color(0xFFBB86FC) : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isFilled ? Colors.white : Colors.white12,
                    width: isFilled ? 1.0 : 0.5,
                  ),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: const Color(0xFFBB86FC).withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: isFilled
                    ? const Center(
                        child: Icon(Icons.check, size: 10, color: Colors.white),
                      )
                    : null,
              );
            }),
          );
        }),
      ),
    );
  }

  void _showPatternDetailDialog(BuildContext context, BattlePattern p) {
    final bb = p.boundingBox;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.purpleAccent, width: 1.5),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(p.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                p.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Board Placement Matrix",
                style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Enlarged Preview Matrix
              _buildMiniPatternGrid(p, cellSize: 32),
              const SizedBox(height: 16),

              // Stats Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _detailBadge(Icons.grid_on, "Required Tiles", "${p.cells.length} cells"),
                  _detailBadge(Icons.aspect_ratio, "Grid Area", "${bb.rows} × ${bb.cols}"),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141422),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "⚡ Combat Effect:",
                      style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.effectDescription,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "💡 How to Trigger:",
                      style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Correctly fill all ${p.cells.length} highlighted cells in this exact shape anywhere on your 9×9 board.",
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Got it!", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailBadge(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF222238),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.cyanAccent),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
