import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/board.dart';
import '../core/generator.dart';
import '../battle/player.dart';
import '../battle/patterns.dart';
import '../battle/detector.dart';
import '../battle/effects.dart';
import '../network/game_host.dart';
import '../network/game_client.dart';
import '../network/network_message.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/mini_opponent_grid.dart';
import '../widgets/virtual_numpad.dart';
import '../widgets/hp_bar_widget.dart';
import '../widgets/pattern_banner_widget.dart';
import '../widgets/battle_log_widget.dart';

class PvPGameScreen extends StatefulWidget {
  final String playerName;
  final bool isHost;
  final GameHost? hostObj;
  final GameClient? clientObj;

  const PvPGameScreen({
    super.key,
    required this.playerName,
    required this.isHost,
    this.hostObj,
    this.clientObj,
  });

  @override
  State<PvPGameScreen> createState() => _PvPGameScreenState();
}

class _PvPGameScreenState extends State<PvPGameScreen> {
  late Player myPlayer;
  late Player opponentPlayer;
  late SudokuBoard myBoard;
  late SudokuBoard opponentBoard;

  final generator = PuzzleGenerator();
  final detector = PatternDetector();
  final effectEngine = EffectEngine();

  List<BattlePattern> activePatterns = [];
  final Set<String> myTriggeredPatterns = {};
  final List<String> battleLogs = [];

  ({int r, int c})? selectedCell;
  bool isNotesMode = false;
  int roundNumber = 1;
  bool isGameOver = false;

  StreamSubscription? _msgSub;
  StreamSubscription? _connSub;

  @override
  void initState() {
    super.initState();
    myPlayer = Player(name: widget.playerName, playerId: widget.isHost ? 1 : 2);
    opponentPlayer = Player(name: "Lawan", playerId: widget.isHost ? 2 : 1);
    myBoard = SudokuBoard();
    opponentBoard = SudokuBoard();

    _setupNetworkListeners();

    if (widget.isHost) {
      _startHostNewRound();
    }
  }

  void _setupNetworkListeners() {
    final stream = widget.isHost ? widget.hostObj?.messageStream : widget.clientObj?.messageStream;
    final connStream = widget.isHost ? widget.hostObj?.connectionStateStream : widget.clientObj?.connectionStateStream;

    _msgSub = stream?.listen(_handleIncomingMessage);
    _connSub = connStream?.listen((connected) {
      if (!connected && mounted && !isGameOver) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Koneksi lawan terputus!"), backgroundColor: Colors.redAccent),
        );
      }
    });
  }

  void _sendMessage(NetworkMessage msg) {
    if (widget.isHost) {
      widget.hostObj?.send(msg);
    } else {
      widget.clientObj?.send(msg);
    }
  }

  void _startHostNewRound() {
    activePatterns = getRandomPatterns(4);
    final pHost = generator.generate(difficulty: 'medium');
    final pClient = generator.generate(difficulty: 'medium');

    myBoard.loadPuzzle(pHost.puzzle, pHost.solution);
    opponentBoard.loadPuzzle(pClient.puzzle, pClient.solution);
    myTriggeredPatterns.clear();
    myPlayer.resetRoundState();
    opponentPlayer.resetRoundState();

    _sendMessage(NetworkMessage(
      type: "sync_round",
      payload: {
        "round": roundNumber,
        "hostName": widget.playerName,
        "patterns": activePatterns.map((p) => p.id).toList(),
        "pHost": pHost.puzzle,
        "sHost": pHost.solution,
        "pClient": pClient.puzzle,
        "sClient": pClient.solution,
      },
    ));

    setState(() {
      battleLogs.add("⚔️ RONDE $roundNumber DIMULAI!");
    });
  }

  void _handleIncomingMessage(NetworkMessage msg) {
    if (!mounted) return;

    switch (msg.type) {
      case "sync_round":
        final p = msg.payload;
        final patIds = (p["patterns"] as List).cast<String>();
        setState(() {
          roundNumber = p["round"] as int;
          opponentPlayer.name = p["hostName"] as String;
          activePatterns = patternPool.where((item) => patIds.contains(item.id)).toList();
          myBoard.loadPuzzle(
            (p["pClient"] as List).map((row) => (row as List).cast<int>()).toList(),
            (p["sClient"] as List).map((row) => (row as List).cast<int>()).toList(),
          );
          opponentBoard.loadPuzzle(
            (p["pHost"] as List).map((row) => (row as List).cast<int>()).toList(),
            (p["sHost"] as List).map((row) => (row as List).cast<int>()).toList(),
          );
          myTriggeredPatterns.clear();
          myPlayer.resetRoundState();
          opponentPlayer.resetRoundState();
          battleLogs.add("⚔️ RONDE $roundNumber DIMULAI!");
        });
        break;

      case "cell_update":
        final r = msg.payload["r"] as int;
        final c = msg.payload["c"] as int;
        final val = msg.payload["val"] as int;
        final isValid = msg.payload["valid"] as bool;
        setState(() {
          opponentBoard.cells[r][c].value = val;
          opponentBoard.cells[r][c].isValid = isValid;
        });
        break;

      case "cell_clear":
        final r = msg.payload["r"] as int;
        final c = msg.payload["c"] as int;
        setState(() {
          opponentBoard.clearCell(r, c);
        });
        break;

      case "penalty":
        setState(() {
          opponentPlayer.takePenalty();
          battleLogs.add("❌ ${opponentPlayer.name} salah isi! Penalti -1 HP");
          _checkGameOver();
        });
        break;

      case "pattern_effect":
        final dmg = msg.payload["damage"] as int;
        final heal = msg.payload["heal"] as int;
        final scramble = msg.payload["scramble"] as bool;
        final text = msg.payload["message"] as String;

        setState(() {
          if (dmg > 0) myPlayer.takeDamage(dmg);
          if (heal > 0) opponentPlayer.heal(heal);
          if (scramble) {
            final targetCol = Random().nextInt(9);
            myBoard.scrambleColumnUserCells(targetCol);
            battleLogs.add("🔀 Kolom ${targetCol + 1} papanmu diacak lawan!");
          }
          battleLogs.add(text);
          _checkGameOver();
        });
        break;
    }
  }

  void _onCellTapped(int r, int c) {
    setState(() => selectedCell = (r: r, c: c));
  }

  void _onNumberSelected(int num) {
    if (selectedCell == null || !myPlayer.isAlive || isGameOver) return;
    final r = selectedCell!.r;
    final c = selectedCell!.c;

    if (myBoard.cells[r][c].isGiven) return;

    setState(() {
      if (isNotesMode) {
        final notes = myBoard.cells[r][c].notes;
        if (notes.contains(num)) {
          notes.remove(num);
        } else {
          notes.add(num);
        }
      } else {
        final isCorrect = myBoard.setValue(r, c, num);
        _sendMessage(NetworkMessage(
          type: "cell_update",
          payload: {"r": r, "c": c, "val": num, "valid": isCorrect},
        ));

        if (!isCorrect) {
          myPlayer.takePenalty();
          _sendMessage(NetworkMessage(type: "penalty", payload: {}));
          battleLogs.add("❌ Kamu salah isi angka! Penalti -1 HP");
          _checkGameOver();
          return;
        }

        // Cek pola baru terbentuk
        final matches = detector.detectNewPatterns(myBoard, activePatterns, myTriggeredPatterns);
        if (matches.isNotEmpty) {
          final results = effectEngine.applyMatches(matches, myPlayer, opponentPlayer);
          for (final res in results) {
            final key = "${res.pattern.id}_${matches.first.anchor.r}_${matches.first.anchor.c}";
            myTriggeredPatterns.add(key);
            battleLogs.add("🔥 [Kamu] ${res.message}");

            _sendMessage(NetworkMessage(
              type: "pattern_effect",
              payload: {
                "damage": res.damageDealt,
                "heal": res.healAmount,
                "scramble": res.scrambleTriggered,
                "message": "🔥 [${myPlayer.name}] ${res.message}",
              },
            ));
          }
        }

        // Cek apakah selesai ronde
        if (myBoard.isComplete() && myBoard.isCorrect()) {
          opponentPlayer.takeDamage(25);
          battleLogs.add("🏆 Kamu menyelesaikan Sudoku! +25 Damage ke lawan");
          _sendMessage(NetworkMessage(
            type: "pattern_effect",
            payload: {
              "damage": 25,
              "heal": 0,
              "scramble": false,
              "message": "🏆 ${myPlayer.name} menyelesaikan Sudoku lebih dulu! (+25 Damage)",
            },
          ));
          if (widget.isHost && myPlayer.isAlive && opponentPlayer.isAlive) {
            roundNumber++;
            _startHostNewRound();
          }
        }

        _checkGameOver();
      }
    });
  }

  void _onDelete() {
    if (selectedCell == null || !myPlayer.isAlive || isGameOver) return;
    final r = selectedCell!.r;
    final c = selectedCell!.c;
    if (!myBoard.cells[r][c].isGiven) {
      setState(() {
        myBoard.clearCell(r, c);
        _sendMessage(NetworkMessage(
          type: "cell_clear",
          payload: {"r": r, "c": c},
        ));
      });
    }
  }

  void _checkGameOver() {
    if (!myPlayer.isAlive || !opponentPlayer.isAlive) {
      isGameOver = true;
      final isVictory = myPlayer.isAlive && !opponentPlayer.isAlive;
      final isDraw = !myPlayer.isAlive && !opponentPlayer.isAlive;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E2F),
            title: Text(
              isDraw
                  ? "🤝 DRAW (SERI) 🤝"
                  : isVictory
                      ? "👑 VICTORY! 👑"
                      : "💀 DEFEAT! 💀",
              style: TextStyle(
                color: isDraw ? Colors.amberAccent : isVictory ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Text(
              isDraw
                  ? "Kedua pemain gugur bersamaan pada ronde $roundNumber!"
                  : isVictory
                      ? "Selamat! Kamu berhasil mengalahkan ${opponentPlayer.name}!"
                      : "HP kamu habis. Pemenang: ${opponentPlayer.name}!",
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text("Kembali ke Lobby"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        title: Text("PvP Battle — Ronde $roundNumber", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: MiniOpponentGridWidget(board: opponentBoard),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(child: HpBarWidget(player: myPlayer)),
                  const SizedBox(width: 8),
                  Expanded(child: HpBarWidget(player: opponentPlayer, isOpponent: true)),
                ],
              ),
            ),
            PatternBannerWidget(activePatterns: activePatterns),
            BattleLogWidget(logs: battleLogs),
            Expanded(
              child: Center(
                child: SudokuGridWidget(
                  board: myBoard,
                  selectedCell: selectedCell,
                  onCellTapped: _onCellTapped,
                ),
              ),
            ),
            VirtualNumpad(
              onNumberSelected: _onNumberSelected,
              onDelete: _onDelete,
              onHint: () {},
              onToggleNotes: () => setState(() => isNotesMode = !isNotesMode),
              isNotesMode: isNotesMode,
              hintsRemaining: 0,
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
