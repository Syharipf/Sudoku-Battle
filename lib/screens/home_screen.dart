import 'package:flutter/material.dart';
import 'solo_game_screen.dart';
import 'pvp_lobby_screen.dart';
import 'patterns_guide_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1A), Color(0xFF1B1B2F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title & Logo
                  const Icon(Icons.grid_4x4, size: 72, color: Colors.cyanAccent),
                  const SizedBox(height: 12),
                  const Text(
                    "SUDOKU BATTLE",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "⚔️ ANDROID OFFLINE LAN EDITION ⚔️",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Menu Buttons
                  _buildMenuCard(
                    context,
                    title: "SOLO MODE",
                    subtitle: "Bermain santai / latihan dengan sistem HP",
                    icon: Icons.play_arrow_rounded,
                    color: Colors.cyanAccent,
                    onTap: () => _showDifficultyDialog(context),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: "PVP OFFLINE (HOTSPOT / LAN)",
                    subtitle: "Tantang teman via Wi-Fi Hotspot tanpa internet",
                    icon: Icons.wifi_tethering,
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PvPLobbyScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: "PANDUAN & POLA SERANGAN",
                    subtitle: "Pelajari 11 pola serangan & efek battle",
                    icon: Icons.menu_book_rounded,
                    color: Colors.amberAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PatternsGuideScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF222238),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2F),
          title: const Text("Pilih Tingkat Kesulitan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _diffOption(ctx, "Easy", "easy", Colors.greenAccent),
              _diffOption(ctx, "Medium", "medium", Colors.cyanAccent),
              _diffOption(ctx, "Hard", "hard", Colors.amberAccent),
              _diffOption(ctx, "Expert", "expert", Colors.redAccent),
            ],
          ),
        );
      },
    );
  }

  Widget _diffOption(BuildContext context, String label, String diffKey, Color color) {
    return ListTile(
      leading: Icon(Icons.bolt, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SoloGameScreen(difficulty: diffKey),
          ),
        );
      },
    );
  }
}
