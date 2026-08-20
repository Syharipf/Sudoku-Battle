import 'package:flutter/material.dart';

/// Widget Log Pesan Serangan Real-time.
class BattleLogWidget extends StatelessWidget {
  final List<String> logs;

  const BattleLogWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final recentLogs = logs.reversed.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recentLogs.isEmpty
            ? [const Text("Menunggu aksi battle...", style: TextStyle(color: Colors.white30, fontSize: 11, fontStyle: FontStyle.italic))]
            : recentLogs.map((log) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Text(
                    log,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
      ),
    );
  }
}
