import 'package:flutter/material.dart';

/// Ergonomic, Large Touch Keypad for Mobile Sudoku.
class VirtualNumpad extends StatelessWidget {
  final Function(int) onNumberSelected;
  final VoidCallback onDelete;
  final VoidCallback onHint;
  final VoidCallback onToggleNotes;
  final bool isNotesMode;
  final int hintsRemaining;
  final Set<int> completedNumbers;

  const VirtualNumpad({
    super.key,
    required this.onNumberSelected,
    required this.onDelete,
    required this.onHint,
    required this.onToggleNotes,
    this.isNotesMode = false,
    this.hintsRemaining = 3,
    this.completedNumbers = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF141422),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action Controls: Notes & Hint Bar
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: onToggleNotes,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isNotesMode ? Colors.amberAccent.withOpacity(0.2) : const Color(0xFF1E1E30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isNotesMode ? Colors.amberAccent : Colors.white24,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isNotesMode ? Icons.edit : Icons.edit_outlined,
                            size: 16,
                            color: isNotesMode ? Colors.amberAccent : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isNotesMode ? "NOTES: ON" : "NOTES",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isNotesMode ? Colors.amberAccent : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: InkWell(
                    onTap: onHint,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD600), Color(0xFFFFAB00)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lightbulb, size: 16, color: Colors.black87),
                          const SizedBox(width: 6),
                          Text(
                            "HINT ($hintsRemaining)",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Row 1: Numbers 1 to 5 (Wide, Ergonomic, Thumb-friendly)
          Row(
            children: [
              _buildNumberKey(1),
              _buildNumberKey(2),
              _buildNumberKey(3),
              _buildNumberKey(4),
              _buildNumberKey(5),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: Numbers 6 to 9 + Erase Button
          Row(
            children: [
              _buildNumberKey(6),
              _buildNumberKey(7),
              _buildNumberKey(8),
              _buildNumberKey(9),
              _buildEraseKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberKey(int number) {
    final isCompleted = completedNumbers.contains(number);

    if (isCompleted) {
      // Completed Number: Hidden / Dimmed out with checkmark indicator
      return Expanded(
        child: Container(
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.greenAccent.withOpacity(0.3),
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: const Color(0xFF222238),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => onNumberSelected(number),
            borderRadius: BorderRadius.circular(10),
            splashColor: Colors.cyanAccent.withOpacity(0.3),
            highlightColor: Colors.cyanAccent.withOpacity(0.15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
              ),
              alignment: Alignment.center,
              child: Text(
                "$number",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEraseKey() {
    return Expanded(
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: const Color(0xFF381E28),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(10),
            splashColor: Colors.redAccent.withOpacity(0.4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4), width: 1.2),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.backspace_rounded,
                color: Colors.redAccent,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
