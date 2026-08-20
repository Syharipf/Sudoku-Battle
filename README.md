# 📱 Sudoku Battle: Android Mobile Edition (Offline LAN / Hotspot)

A competitive mobile Sudoku game for Android that can be played **100% offline** (no internet connection required) both in **Solo Practice** and **Multiplayer PvP** mode via **Portable Wi-Fi Hotspot / LAN**!

---

## ⚡ Download APK & Play on Mobile

Every update or commit to the `main` branch automatically triggers **GitHub Actions CI/CD** to build the Android release APK (`app-release.apk`).

1. Open the **Releases** tab or **Actions** tab on this GitHub repository.
2. Download **`app-release.apk`**.
3. Install the APK on your Android device (enable *Install unknown apps* if prompted).
4. Enjoy! The game is ready to play.

---

## ✨ Key Features

- **📱 Touch-Optimized UI & Ergonomic Numpad:** Responsive 9×9 grid navigation, comfortable two-row virtual numpad with large touch targets (1–9, Erase, Notes, Hint).
- **⚔️ Real-Time PvP via Hotspot:** Player 1 opens Portable Hotspot & hosts room, Player 2 connects to Wi-Fi and joins via local IP (`192.168.43.1:7777`).
- **❤️ 100 HP & Penalty System:** Wrong cell input = **-1 HP Penalty**. Reach 0 HP = Defeat!
- **🎯 11 Battle Patterns:**
  - **✚ Cross:** Deal -15 HP damage
  - **♥ Mini Heart:** Restore +10 HP
  - **🔀 Column Chaos (Scramble):** Scramble opponent board column + Deal -7 HP
  - **🛡️ Box 2×2:** Shield to block 1 incoming attack
  - **↗ Diagonal:** ×1.5 Damage Multiplier on next attack
  - **⚡ Zigzag, ➡ Row Streak, ⬇ Column Streak, 🗡️ T-Shape, ✖ X-Wing**
- **💡 Dynamic Hint Column:** A random column glows yellow every ~30 seconds for bonus free hints.
- **👀 Opponent Mini-Grid:** Real-time mini-preview of the opponent's puzzle progress in the corner.

---

## 📁 Project Structure (Flutter / Dart)

```
Sudoku Battle/
├── .github/
│   └── workflows/
│       └── build-apk.yml       # GitHub Actions CI/CD pipeline (Auto Build APK & Release)
├── pubspec.yaml
├── android/
│   ├── build.gradle
│   ├── settings.gradle
│   ├── gradle.properties
│   └── app/
│       ├── build.gradle
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/com/example/sudoku_battle/MainActivity.kt
└── lib/
    ├── main.dart
    ├── core/
    │   ├── board.dart          # 9x9 board logic, Hint Column, Column Scramble
    │   ├── generator.dart      # Unique puzzle generator
    │   ├── validator.dart      # Sudoku row, column, 3x3 box validator
    │   └── solver.dart         # MCV hint algorithm & column bonus hints
    ├── battle/
    │   ├── player.dart         # HP, Shield, Multiplier, Penalty model
    │   ├── patterns.dart       # Pool of 11 battle patterns & effect definitions
    │   ├── detector.dart       # Pattern detector from player-filled cells
    │   └── effects.dart        # Engine for damage, heal, shield, and scramble
    ├── network/
    │   ├── network_message.dart# JSON network protocol
    │   ├── game_host.dart      # Local socket server on Host device (Port 7777)
    │   └── game_client.dart    # Socket client on Challenger device
    ├── screens/
    │   ├── home_screen.dart    # Main menu
    │   ├── solo_game_screen.dart# Solo practice mode
    │   ├── pvp_lobby_screen.dart# Host / Join LAN lobby
    │   ├── pvp_game_screen.dart # Real-time PvP arena with mini-preview
    │   └── patterns_guide_screen.dart # 11 patterns visual guide
    └── widgets/
        ├── sudoku_grid.dart    # Interactive 9x9 board
        ├── mini_opponent_grid.dart # Opponent live mini-preview
        ├── virtual_numpad.dart # Ergonomic 2-row virtual keypad
        ├── hp_bar_widget.dart  # Animated HP bar & shield/buff badges
        ├── pattern_banner_widget.dart # Active patterns horizontal list
        └── battle_log_widget.dart # Real-time combat log
```

---

## 🌐 How to Play Multiplayer Offline (No Internet Required)

1. **Phone 1 (Host):** Turn on **Portable Hotspot / Tethering** in Android Settings.
2. **Phone 2 (Client):** Connect Wi-Fi to Phone 1's Hotspot.
3. Open **Sudoku Battle** on both phones.
4. **Phone 1:** Select `PVP OFFLINE` → Tap **CREATE ROOM (HOST)**.
5. **Phone 2:** Select `PVP OFFLINE` → Enter Host IP (usually `192.168.43.1`) → Tap **JOIN ROOM (CLIENT)**.
6. The real-time Sudoku battle begins immediately!
