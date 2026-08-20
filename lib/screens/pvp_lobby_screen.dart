import 'package:flutter/material.dart';
import '../network/game_host.dart';
import '../network/game_client.dart';
import 'pvp_game_screen.dart';

/// PvP Lobby Screen for LAN / Hotspot Host & Join.
class PvPLobbyScreen extends StatefulWidget {
  const PvPLobbyScreen({super.key});

  @override
  State<PvPLobbyScreen> createState() => _PvPLobbyScreenState();
}

class _PvPLobbyScreenState extends State<PvPLobbyScreen> {
  final TextEditingController _nameController = TextEditingController(text: "Player");
  final TextEditingController _ipController = TextEditingController(text: "192.168.43.1");

  bool isHosting = false;
  bool isConnecting = false;
  String? hostAddress;
  GameHost? host;
  GameClient? client;

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    host?.stop();
    client?.disconnect();
    super.dispose();
  }

  Future<void> _startHost() async {
    setState(() => isHosting = true);
    host = GameHost();
    final ip = await host!.startHost();
    setState(() => hostAddress = "$ip:7777");

    host!.connectionStateStream.listen((connected) {
      if (connected && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PvPGameScreen(
              playerName: _nameController.text.trim().isEmpty ? "Host" : _nameController.text.trim(),
              isHost: true,
              hostObj: host,
            ),
          ),
        );
      }
    });
  }

  Future<void> _joinHost() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;

    setState(() => isConnecting = true);
    client = GameClient();
    final success = await client!.connect(ip);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PvPGameScreen(
            playerName: _nameController.text.trim().isEmpty ? "Challenger" : _nameController.text.trim(),
            isHost: false,
            clientObj: client,
          ),
        ),
      );
    } else {
      if (mounted) {
        setState(() => isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Failed to connect to host! Ensure both devices are on the same Wi-Fi / Hotspot."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        title: const Text("PVP OFFLINE (LAN / HOTSPOT)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Your Nickname",
                labelStyle: const TextStyle(color: Colors.cyanAccent),
                prefixIcon: const Icon(Icons.person, color: Colors.cyanAccent),
                filled: true,
                fillColor: const Color(0xFF1E1E2F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // HOST ROOM CARD
            Card(
              color: const Color(0xFF222238),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.wifi_tethering, color: Colors.redAccent, size: 28),
                        SizedBox(width: 12),
                        Text(
                          "CREATE ROOM (HOST)",
                          style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Phone 1 turns on Portable Hotspot, then starts hosting here.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    if (isHosting) ...[
                      const CircularProgressIndicator(color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        "Waiting for Opponent...\nHost IP: $hostAddress",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          host?.stop();
                          setState(() {
                            isHosting = false;
                            hostAddress = null;
                          });
                        },
                        child: const Text("Cancel"),
                      ),
                    ] else
                      ElevatedButton.icon(
                        onPressed: _startHost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Start Host Server"),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // JOIN ROOM CARD
            Card(
              color: const Color(0xFF222238),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.link, color: Colors.cyanAccent, size: 28),
                        SizedBox(width: 12),
                        Text(
                          "JOIN ROOM (CLIENT)",
                          style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Phone 2 connects Wi-Fi to Phone 1's Hotspot, enter Host IP, then tap Join.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ipController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Host IP (Hotspot Default: 192.168.43.1)",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.router, color: Colors.cyanAccent),
                        filled: true,
                        fillColor: const Color(0xFF14141F),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isConnecting)
                      const CircularProgressIndicator(color: Colors.cyanAccent)
                    else
                      ElevatedButton.icon(
                        onPressed: _joinHost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.login),
                        label: const Text("Join Host Room", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
