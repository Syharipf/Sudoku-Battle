import 'dart:async';
import 'package:flutter/material.dart';
import '../core/board.dart';
import '../core/generator.dart';
import '../core/solver.dart';
import '../battle/player.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/virtual_numpad.dart';
import '../widgets/hp_bar_widget.dart';

class SoloGameScreen extends StatefulWidget {
  final String difficulty;

  const SoloGameScreen({super.key, this.difficulty = 'medium'});

  @override
  State<SoloGameScreen> createState() => _SoloGameScreenState();
}

class _SoloGameScreenState extends State<SoloGameScreen> {
  late SudokuBoard board;
  late Player player;
  final generator = PuzzleGenerator();
  final solver = SudokuSolver();

  ({int r, int c})? selectedCell;
  bool isNotesMode = false;
  int hintsUsed = 0;
  static const int maxHints = 3;

  int secondsElapsed = 0;
  Timer? gameTimer;
  Timer? hintColumnTimer;
  String statusMessage = "Welcome! Select a cell & enter a number.";

  @override
  void initState() {
    super.initState();
    board = SudokuBoard();
    player = Player(name: "Player", playerId: 1);
    _startNewGame();
  }

  void _startNewGame() {
    final result = generator.generate(difficulty: widget.difficulty);
    board.loadPuzzle(result.puzzle, result.solution);
    player.resetForNewGame();
    hintsUsed = 0;
    secondsElapsed = 0;
    selectedCell = null;

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && player.isAlive && !board.isComplete()) {
        setState(() => secondsElapsed++);
      }
    });

    _startHintColumnCycle();
  }

  void _startHintColumnCycle() {
    hintColumnTimer?.cancel();
    hintColumnTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && player.isAlive && !board.isComplete()) {
        final chosenCol = solver.pickRandomHintColumn(board);
        if (chosenCol != null) {
          setState(() {
            board.hintColumn = chosenCol;
            statusMessage = "💡 BONUS: Column ${chosenCol + 1} active as Hint Column! (Tap Hint)";
          });

          // Disappears after 15 seconds
          Future.delayed(const Duration(seconds: 15), () {
            if (mounted) {
              setState(() => board.hintColumn = null);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    hintColumnTimer?.cancel();
    super.dispose();
  }

  void _onCellTapped(int r, int c) {
    setState(() {
      selectedCell = (r: r, c: c);
    });
  }

  void _onNumberSelected(int num) {
    if (selectedCell == null || !player.isAlive) return;
    final r = selectedCell!.r;
    final c = selectedCell!.c;

    if (board.cells[r][c].isGiven) return;

    setState(() {
      if (isNotesMode) {
        final notes = board.cells[r][c].notes;
        if (notes.contains(num)) {
          notes.remove(num);
        } else {
          notes.add(num);
        }
      } else {
        final isCorrect = board.setValue(r, c, num);
        if (!isCorrect) {
          player.takePenalty();
          statusMessage = "❌ Number $num is wrong! -1 HP Penalty (Remaining HP: ${player.hp})";
          if (!player.isAlive) _showGameOverDialog(false);
        } else {
          statusMessage = "✅ Number $num placed correctly!";
          if (board.isComplete() && board.isCorrect()) {
            _showGameOverDialog(true);
          }
        }
      }
    });
  }

  void _onDelete() {
    if (selectedCell == null || !player.isAlive) return;
    final r = selectedCell!.r;
    final c = selectedCell!.c;
    if (!board.cells[r][c].isGiven) {
      setState(() {
        board.clearCell(r, c);
        statusMessage = "Cell cleared.";
      });
    }
  }

  void _onHint() {
    if (!player.isAlive) return;

    // Check if Hint Column is active
    if (board.hintColumn != null) {
      final col = board.hintColumn!;
      final hints = solver.getHintsForColumn(board, col);
      if (hints.isNotEmpty) {
        final h = hints.first;
        setState(() {
          board.setValue(h.r, h.c, h.val);
          selectedCell = (r: h.r, c: h.c);
          statusMessage = "💡 [Bonus Hint Column] Cell (${h.r + 1}, ${h.c + 1}) filled with ${h.val}!";
          if (board.isComplete() && board.isCorrect()) _showGameOverDialog(true);
        });
        return;
      }
    }

    if (hintsUsed >= maxHints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Standard hint limit reached (max 3)!"), duration: Duration(seconds: 1)),
      );
      return;
    }

    final hintPos = solver.getHintCell(board);
    if (hintPos != null) {
      final sol = board.solution;
      if (sol != null) {
        final val = sol[hintPos.r][hintPos.c];
        setState(() {
          board.setValue(hintPos.r, hintPos.c, val);
          selectedCell = (r: hintPos.r, c: hintPos.c);
          hintsUsed++;
          player.stats.hintsUsed++;
          statusMessage = "💡 [Hint $hintsUsed/$maxHints] Cell (${hintPos.r + 1}, ${hintPos.c + 1}) filled with $val.";
          if (board.isComplete() && board.isCorrect()) _showGameOverDialog(true);
        });
      }
    }
  }

  void _showGameOverDialog(bool isVictory) {
    gameTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2F),
          title: Text(
            isVictory ? "🎉 VICTORY! 🎉" : "💀 GAME OVER 💀",
            style: TextStyle(
              color: isVictory ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isVictory
                    ? "Awesome! You solved the ${widget.difficulty.toUpperCase()} puzzle!"
                    : "You ran out of HP from cell input penalties.",
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text("⏱️ Time: ${_formatTime(secondsElapsed)}", style: const TextStyle(color: Colors.white)),
              Text("❤️ Remaining HP: ${player.hp}/${Player.maxHp}", style: const TextStyle(color: Colors.white)),
              Text("❌ Mistakes: ${player.stats.penaltyCount}", style: const TextStyle(color: Colors.white)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Main Menu"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _startNewGame());
              },
              child: const Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        title: Text("Solo (${widget.difficulty.toUpperCase()})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "⏱️ ${_formatTime(secondsElapsed)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.cyanAccent),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: HpBarWidget(player: player),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                statusMessage,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Center(
                child: SudokuGridWidget(
                  board: board,
                  selectedCell: selectedCell,
                  onCellTapped: _onCellTapped,
                ),
              ),
            ),
            VirtualNumpad(
              onNumberSelected: _onNumberSelected,
              onDelete: _onDelete,
              onHint: _onHint,
              onToggleNotes: () => setState(() => isNotesMode = !isNotesMode),
              isNotesMode: isNotesMode,
              hintsRemaining: maxHints - hintsUsed,
            ),
          ],
        ),
      ),
    );
  }
}
