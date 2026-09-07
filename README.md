# kokorokami-hzr

[![Zig](https://img.shields.io/badge/Zig-0.13%20%7C%200.16-F7A41D?style=for-the-badge&logo=zig&logoColor=white)](https://ziglang.org/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Android%20%7C%20macOS%20%7C%20Windows-44cc11?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/kouzen-neo/kokorokami-hzr)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Build-Passing-brightgreen?style=for-the-badge)]()

A local private server emulator for **Haze Reverb (绯色回响 / 殘機為零)** (`com.gennmugame.hazereverb`), written in **[Zig](https://ziglang.org/)**.

Designed for game preservation and offline playability. Works with the official, unmodified game client.

---

## Quick Start

### Mode 1: Desktop Server (Laptop / PC)

Run the server on your computer and connect your phone or emulator over the same Wi-Fi / LAN.

1. **Build & Run**:
   ```bash
   # Build executable
   zig build -Doptimize=ReleaseFast

   # Run passing your machine's LAN IP
   ./zig-out/bin/server_haze <HOST_IP>
   ```
   - HTTP Gateway binds to `http://0.0.0.0:8100`
   - TCP GameServer binds to `0.0.0.0:8888`

2. **Redirect Client**:
   Point `cwveren2.feimogames.com` to your machine's IP (via `/system/etc/hosts`, router DNS, or a hosts VPN app).
3. Launch **Haze Reverb** and start playing!

---

### Mode 2: Android Companion App (Standalone Offline)

Host and play entirely on an Android phone without needing a PC or root access.

1. **Build Companion APK**:
   ```bash
   zig build apk
   ```
   Output: `haze_companion_app/build/HazeCompanion.apk`

2. **Install & Play**:
   - Install `HazeCompanion.apk` on your device.
   - Open the app, tap **START SERVER & VPN**, and accept the one-time VPN prompt.
   - Launch the standard **Haze Reverb** game and tap **TOUCH TO START**.

---

## Features at a Glance

- **Profile & Progression**: Level 100 max commander, all 173 drivers unlocked, max currencies, and 717 stages pre-cleared with 3-star status.
- **Gameplay Systems**: 1-tap stage sweep (raid), dynamic battle settlement, and tutorial bypass.
- **Gacha & Recruitment**: 44 summon pools active with single and multi-pull support.
- **Dormitory & Office**: Custom secretary, room furniture placement, and skin shop browsing.

---

## Project Structure

```text
.
├── build.zig                 # Zig build configuration (zig build, zig build apk)
├── server/                   # Native Zig server source code
│   ├── main.zig              # Desktop entry point (Gateway + GameServer)
│   ├── jni.zig               # Android JNI shared library bridge (libserver_haze.so)
│   ├── gateway.zig           # HTTP REST Gateway (CDN manifests, login, versioning)
│   ├── gameserver.zig        # TCP socket server & packet router
│   ├── protocol.zig          # Binary packet framing & Protobuf codecs
│   └── data_tables.zig       # Game data tables (drivers, stages, pools)
├── haze_companion_app/       # Android Companion App (standalone offline host)
├── tools/
│   └── build_apk.zig         # Standalone APK build script
├── server_assets/            # Manifest files, version indices, and patched Lua bundles
├── downloaded_data/          # Protobuf schema definitions (.proto)
└── DOCUMENTATION.md          # Technical documentation & protocol specifications
```

---

## Documentation

For comprehensive technical details, packet framing layouts, the MID registry table, HTTP endpoints, and Android internals, see [DOCUMENTATION.md](DOCUMENTATION.md).

---

## Disclaimer & License

### Disclaimer
This project is developed strictly for private research, local reverse engineering, and educational game preservation purposes. All game assets, trademarks, character designs, and audio files are the intellectual property of their respective creators and publishers (**Feimo Games** / **GENNMU**).

### License
This project is open-source software licensed under the [MIT License](LICENSE).
