# 📱 Sudoku Battle: Android Mobile Edition (Offline LAN / Hotspot)

Game Sudoku kompetitif berbasis mobile Android yang dapat dimainkan **100% offline** (tanpa kuota internet) baik **Solo** maupun **Multiplayer PvP** melalui koneksi **Portable Wi-Fi Hotspot / LAN** antar-HP!

---

## ✨ Fitur Utama Mobile

- **📱 Touch-Optimized UI:** Navigasi tap sel responsif, grid 9×9 proporsional, serta Virtual Numpad (1–9, Erase, Notes, Hint).
- **⚔️ Real-Time PvP via Hotspot:** HP 1 membuka Portable Hotspot & Room, HP 2 terhubung ke Wi-Fi dan langsung join via IP lokal (`192.168.43.1:7777`).
- **❤️ Sistem HP 100 & Penalti:** Salah mengisi angka = **-1 HP**. HP habis = Kalah!
- **🎯 11 Pola Serangan (Battle Patterns):**
  - **✚ Cross:** Serang -15 HP
  - **♥ Mini Heart:** Heal +10 HP
  - **🔀 Column Chaos (Scramble):** Acak kolom papan lawan + Damage -7 HP
  - **🛡️ Box 2×2:** Shield pemblokir 1 serangan
  - **↗ Diagonal:** Damage Multiplier ×1.5
  - **⚡ Zigzag, ➡ Row Streak, ⬇ Col Streak, 🗡️ T-Shape, ✖ X-Wing**
- **💡 Dynamic Hint Column:** Kolom acak menyala kuning setiap ~30 detik untuk hint gratis.
- **👀 Opponent Mini-Grid:** Pemain dapat melihat live progress papan lawan di pojok layar.

---

## 📁 Struktur Proyek (Flutter / Dart)

```
sudoku_mobile/
├── pubspec.yaml
├── android/
│   └── app/src/main/AndroidManifest.xml
└── lib/
    ├── main.dart
    ├── core/
    │   ├── board.dart          # Logika papan 9x9, Hint Column, Column Scramble
    │   ├── generator.dart      # Generator puzzle solusi unik
    │   ├── validator.dart      # Validasi aturan baris, kolom, 3x3 box
    │   └── solver.dart         # MCV hint algorithm & bonus column hints
    ├── battle/
    │   ├── player.dart         # Model HP, Shield, Multiplier, Penalti
    │   ├── patterns.dart       # Pool 11 pola serangan & definisi efek
    │   ├── detector.dart       # Detektor bentuk pola dari user-filled cells
    │   └── effects.dart        # Engine pengaplikasian damage, heal, scramble
    ├── network/
    │   ├── network_message.dart# Format JSON protocol
    │   ├── game_host.dart      # Server socket lokal di HP Host (Port 7777)
    │   └── game_client.dart    # Socket client di HP Challenger
    ├── screens/
    │   ├── home_screen.dart    # Menu utama
    │   ├── solo_game_screen.dart# Mode solo touch
    │   ├── pvp_lobby_screen.dart# Host / Join LAN Hotspot
    │   ├── pvp_game_screen.dart # Layar pertarungan PvP split-preview
    │   └── patterns_guide_screen.dart # Panduan 11 pola
    └── widgets/
        ├── sudoku_grid.dart    # Grid 9x9 interaktif
        ├── mini_opponent_grid.dart # Mini-preview papan lawan
        ├── virtual_numpad.dart # Keypad virtual
        ├── hp_bar_widget.dart  # Bar HP animasi & status shield/buff
        ├── pattern_banner_widget.dart # Daftar pola aktif
        └── battle_log_widget.dart # Log serangan real-time
```

---

## 🚀 Cara Menjalankan / Build ke Android

Pastikan kamu memiliki **Flutter SDK**:

```bash
# Masuk ke folder mobile
cd sudoku_mobile

# Ambil dependencies
flutter pub get

# Jalankan di emulator / HP Android yang terhubung via USB
flutter run

# Atau build APK Release offline
flutter build apk --release
```

---

## 🌐 Cara Bermain Multiplayer Tanpa Internet (Offline Hotspot)

1. **HP 1 (Host):** Nyalakan **Hotspot Portabel / Tethering** di pengaturan Android.
2. **HP 2 (Client):** Sambungkan Wi-Fi ke Hotspot HP 1.
3. Buka game **Sudoku Battle** di kedua HP.
4. **HP 1:** Pilih `PVP OFFLINE` → Tap **Buat Room (Host)**.
5. **HP 2:** Pilih `PVP OFFLINE` → Masukkan IP Host (biasanya `192.168.43.1`) → Tap **Gabung ke Host**.
6. Pertarungan Sudoku real-time langsung dimulai!
