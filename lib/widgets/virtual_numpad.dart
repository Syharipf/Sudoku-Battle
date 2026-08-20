import 'package:flutter/material.dart';

/// Virtual Keypad Touch untuk Layar HP Android (1-9, Delete, Hint, Notes).
class VirtualNumpad extends StatelessWidget {
  final Function(int) onNumberSelected;
  final VoidCallback onDelete;
  final VoidCallback onHint;
  final VoidCallback onToggleNotes;
  final bool isNotesMode;
  final int hintsRemaining;

  const VirtualNumpad({
    super.key,
    required this.onNumberSelected,
    required this.onDelete,
    required this.onHint,
    required this.onToggleNotes,
    this.isNotesMode = false,
    this.hintsRemaining = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Action Row: Notes & Hint
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggleNotes,
                  icon: Icon(
                    isNotesMode ? Icons.edit : Icons.edit_outlined,
                    size: 16,
                    color: isNotesMode ? Colors.amberAccent : Colors.white70,
                  ),
                  label: Text(
                    isNotesMode ? "Notes: ON" : "Notes",
                    style: TextStyle(
                      fontSize: 12,
                      color: isNotesMode ? Colors.amberAccent : Colors.white70,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isNotesMode ? Colors.amberAccent : Colors.white24,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onHint,
                  icon: const Icon(Icons.lightbulb_outline, size: 16, color: Colors.black),
                  label: Text(
                    "Hint ($hintsRemaining)",
                    style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onDelete,
                icon: const Icon(Icons.backspace_outlined, size: 18),
                tooltip: "Hapus",
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Numpad 1-9 Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(9, (index) {
              final number = index + 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    onPressed: () => onNumberSelected(number),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A3E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                    ),
                    child: Text(
                      "$number",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
