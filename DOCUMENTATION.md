# Technical Documentation: kokorokami-hzr

Comprehensive technical reference, protocol specification, and architecture overview for the **Haze Reverb (绯色回响 / 殘機為零)** (`com.gennmugame.hazereverb`) server emulator.

---

## Table of Contents
1. [Architecture & Deployment](#architecture--deployment)
   - [Method 1: Desktop Server (LAN)](#method-1-desktop-server-lan)
   - [Method 2: Android Companion App (Offline VPN Loopback)](#method-2-android-companion-app-offline-vpn-loopback)
2. [Game Features & Injected State](#game-features--injected-state)
   - [Full Player Profile](#full-player-profile)
   - [Currencies & Items](#currencies--items)
   - [Progression & Stage Sweep](#progression--stage-sweep)
   - [Gacha & Banners](#gacha--banners)
   - [Dormitory, Commander Office & Skins](#dormitory-commander-office--skins)
   - [Tutorial Bypass](#tutorial-bypass)
3. [Protocol Specification](#protocol-specification)
   - [Binary Packet Framing](#binary-packet-framing)
   - [Message ID (MID) Registry](#message-id-mid-registry)
   - [HTTP Gateway Endpoints](#http-gateway-endpoints)
4. [Android Companion Internals](#android-companion-internals)
   - [Build Pipeline (tools/build_apk.zig)](#build-pipeline-toolsbuild_apkzig)
   - [JNI & Android Framework Integration](#jni--android-framework-integration)
   - [DNS Loopback Implementation](#dns-loopback-implementation)
5. [Reverse Engineering Notes](#reverse-engineering-notes)

---

## Architecture & Deployment

The emulator consists of two main services written in Zig:
- **HTTP REST Gateway** (Port `8100`): Emulates CDN manifests, client version checks, server listings, and initial authentication (`/httpLogin`).
- **TCP GameServer** (Port `8888`): Handles stateful binary game communication, gacha recruitment, quest completions, team management, and heartbeat signals.

### Method 1: Desktop Server (LAN)

```text
+-----------------------+                    +-----------------------+
|  Android Device /     |   Wi-Fi / LAN      |  PC / Laptop          |
|  Emulator             |------------------->|  (server_haze)        |
|  (Official APK)       |                    |  Gateway:    :8100    |
+-----------------------+                    |  GameServer: :8888    |
                                             +-----------------------+
```

1. **Compilation**:
   ```bash
   zig build -Doptimize=ReleaseFast
   ```
2. **Execution**:
   ```bash
   ./zig-out/bin/server_haze <HOST_IP>
   ```
3. **Redirection**:
   The client resolves `cwveren2.feimogames.com`. Route this domain to `<HOST_IP>` via `/system/etc/hosts`, router DNS (e.g. Dnsmasq/Pi-hole), or a VPN hosts utility.

### Method 2: Android Companion App (Offline VPN Loopback)

```text
+-------------------------------------------------------------+
|                      Android Phone                          |
|                                                             |
|  +---------------------------+   DNS Query (port 53)        |
|  |  Official Haze Reverb     |-----------------------+      |
|  |  Game Client              |                       |      |
|  +---------------------------+                       v      |
|               |                        +------------------+ |
|               | Connect (127.0.0.1)    | Local DNS VPN    | |
|               v                        | (tun0 interface) | |
|  +---------------------------+         +------------------+ |
|  |  Haze Companion Service   |                               |
|  |  (libserver_haze.so)      |<------------------------------+
|  |  - Gateway    :8100       |   Redirects cwveren2...      |
|  |  - GameServer :8888       |   to 127.0.0.1               |
|  +---------------------------+                              |
+-------------------------------------------------------------+
```

1. **Native Engine**: `server/jni.zig` is compiled into an ARM64 shared library (`libserver_haze.so`).
2. **Local DNS VPN**: `LocalDnsVpnService.java` constructs an in-process TUN interface that intercepts port 53 DNS lookups. Queries for `cwveren2.feimogames.com` return `127.0.0.1`, while all other queries pass to public upstream resolvers (`8.8.8.8`).
3. **Zero Modifications**: Works directly with the official, unpatched game APK (`com.gennmugame.hazereverb`).

---

## Game Features & Injected State

### Full Player Profile
Upon receiving `CLIENT_VERIFY_REQ` (`MID 1001`), the server responds with a populated `PBClient.ClientUserInfoNTF` (`MID 1003`):
- **Commander**: Level 100 Max (UID `10001`).
- **Drivers**: All 173 drivers unlocked at Max Level 100, 6 Stars, and maxed skill levels.

### Currencies & Items
| Item ID | Currency / Item Name | Injected Amount |
| :--- | :--- | :--- |
| `100001` | Free Diamonds (Gem) | `999,999` |
| `100008` | Paid Diamonds (Prime Crystalline) | `999,999` |
| `100002` | Gold / Coins | `99,000,000` |
| `100003` | Energy / Stamina | `99,999 / 200` |
| `100004` | Honor / Arena Coin | `999,999` |
| `100005` | Guild Coin | `999,999` |
| `100006` | Friendship Point | `999,999` |
| `100007` | Memory Shard | `999,999` |
| Various  | Summon Tickets (Common, Elite, Ace, Transcendant, Event, Festival) | `99,999x` each |

### Progression & Stage Sweep
- **717 Stages Pre-Cleared**: Normal & Hard main story chapters, Daily Resource Dungeons, Core Trials, and Awakening stages are marked as 3-star cleared (`star = 7`, bitmask `0b111`).
- **Instant Sweep**: One-tap stage sweep (`CLIENT_SWEEP_LEVEL_REQ`) executes immediately without entering the combat loop.
- **Battle Settlement**: `CLIENT_BATTLE_REPORT_REQ` and `CLIENT_BATTLE_SETTLE_REQ` return positive status codes, granting requested battle rewards.

### Gacha & Banners
- All 44 recruitment banners defined in `LotteryLocalData.lua` are enabled.
- Single (1x) and Multi (10x) summons return valid character roll payloads along with SSR animation triggers and collection unlock packets.

### Dormitory, Commander Office & Skins
- **Commander Office**: Dialogue selection, background customization, and custom BGM playback.
- **Dormitory / Ark**: Furniture placement, comfort calculations, and affection gift handling.
- **Skins & Live2D**: Client can browse, inspect, and equip unlocked skins without missing data crashes.

### Tutorial Bypass
- Automatically marks all 70 tutorial milestones (`TutorialLocalData.lua`) as completed, removing forced tutorial scripts and UI restrictions.

---

## Protocol Specification

### Binary Packet Framing

All TCP packets between client and GameServer follow a 16-byte big-endian header format:

```text
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Payload Length (u32 BE)                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Message ID (MID, u32 BE)                   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Tag / Seq (u32 BE)                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       User ID (u32 BE)                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                    Protobuf Payload Data ...                  +
|                    (Size = Payload Length)                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

### Message ID (MID) Registry

| MID | Direction | Name | Description |
| :--- | :--- | :--- | :--- |
| `1000` | C <-> S | `HEARTBEAT` | Connection keep-alive heartbeat |
| `1001` | C -> S | `CLIENT_VERIFY_REQ` | Client authentication request |
| `1002` | S -> C | `CLIENT_VERIFY_ACK` | Verification status (`errNo: 0`) |
| `1003` | S -> C | `CLIENT_VERIFY_NTF` | Player profile injection (Drivers, Items, Stats) |
| `1004` | C -> S | `CLIENT_GOODS_REQ` | Heartbeat / inventory query |
| `1005` | S -> C | `CLIENT_GOODS_ACK` | Inventory acknowledgement |
| `1010` | C -> S | `CLIENT_LEVEL_INFO_REQ` | Stage progress request |
| `1011` | S -> C | `CLIENT_LEVEL_INFO_ACK` | Stage progress status |
| `1012` | S -> C | `CLIENT_LEVEL_INFO_NTF` | Pre-cleared 717 stage records |
| `1013` | C -> S | `CLIENT_RECRUIT_REQ` | Gacha recruitment request (Pool ID, Count) |
| `1014` | S -> C | `CLIENT_RECRUIT_ACK` | Gacha recruitment acknowledgement |
| `1015` | S -> C | `CLIENT_RECRUIT_NTF` | Gacha roll results and character cards |
| `1019` | C -> S | `CLIENT_TASK_PERFORM_REQ` | Task / achievement claim |
| `1020` | S -> C | `CLIENT_TASK_PERFORM_ACK` | Task claim acknowledgement |
| `1021` | S -> C | `CLIENT_TASK_PERFORM_NTF` | Task reward payload |
| `1054` | C -> S | `CLIENT_SWEEP_LEVEL_REQ` | Stage sweep request |
| `1055` | S -> C | `CLIENT_SWEEP_LEVEL_ACK` | Sweep results & item drops |
| `1105` | C -> S | `CLIENT_SET_SECRETARY` | Secretary driver selection |
| `1130` | C -> S | `CLIENT_TEAM_SAVE` | Team composition update |
| `1200` | S -> C | `CLIENT_GET_HOME_DATA_ACK` | Office & main screen state |
| `1236` | S -> C | `CLIENT_GET_ARK_DATA_ACK` | Dormitory room state & layout |
| `1240` | S -> C | `CLIENT_DORM_FURNITURE_ACK` | Furniture placement update |
| `1331` | C -> S | `CLIENT_SHOP_GET_REQ` | Shop catalog query |
| `1332` | S -> C | `CLIENT_SHOP_GET_ACK` | Shop listings & purchase confirmation |
| `*`    | C -> S | Generic Requests | Fallback ACK with `MID + 1` |

### HTTP Gateway Endpoints

| Endpoint | Method | Response Type | Description |
| :--- | :--- | :--- | :--- |
| `/version` | GET | JSON | Client version check and remote status |
| `/api/gate/server_list` | GET/POST | JSON | Server cluster list pointing client to Gateway |
| `/httpLogin` | POST | Protobuf Binary | Serializes `PBClient.ClientLoginResult` pointing to GameServer |
| `/android/bundles/*` | GET | Binary Stream | Asset bundles, manifests, and hotfix patch files |
| `/version_l.txt` | GET | Plaintext | Localization flag (`Localization=true`) |
| `/notice` | GET | JSON | In-game announcements and banners |

---

## Android Companion Internals

### Build Pipeline (`tools/build_apk.zig`)
The companion APK is built using a standalone Zig script (`tools/build_apk.zig`) that can be executed via `zig build apk` or `zig run tools/build_apk.zig -lc`. The pipeline proceeds through 7 steps:
1. **Cross-Compilation**: Compiles `server/jni.zig` for `aarch64-linux-musl` (`-O ReleaseFast -dynamic`) into `libserver_haze.so`.
2. **Asset Packaging**: Copies `server_assets/` into APK assets.
3. **Resource Compilation**: Runs `aapt2 compile` over Android XML resources.
4. **Resource Linking**: Runs `aapt2 link` against `android.jar` to produce `unaligned_res.apk` and generated Java source files (`R.java`).
5. **Java Compilation**: Compiles Java sources with `javac` (`--source 11 --target 11`).
6. **Bytecode Conversion**: Invokes `d8` to convert `.class` files into Dalvik Executable (`classes.dex`).
7. **Packaging & Signing**: Merges resources, DEX, and native `.so` into an APK, aligns byte boundaries via `zipalign -p -f 4`, and signs with `apksigner` (`debug.keystore`).

### JNI & Android Framework Integration
Due to Android's OS security architecture, non-root VPN configuration and foreground service lifecycles require the Android Framework (`android.net.VpnService`, `android.app.NotificationChannel`). The thin Java wrapper coordinates with the native Zig engine:
- `ServerService.java`: Hosts a background thread executing JNI `startServer(...)` and `stopServer(...)`.
- `server/jni.zig`: Exports JNI symbols `Java_com_hazereverb_companion_ServerService_startServer` and `Java_com_hazereverb_companion_ServerService_stopServer`.

### DNS Loopback Implementation
`LocalDnsVpnService.java` reads UDP packets from the virtual TUN file descriptor:
- Inspects incoming DNS queries on port 53.
- If domain matches `cwveren2.feimogames.com`, writes an `A` record pointing to `127.0.0.1`.
- For other hostnames, forwards queries to upstream resolvers (`8.8.8.8`) and relays replies back to TUN.

---

## Reverse Engineering Notes

- **Protobuf Codecs**: Varint encoding/decoding and length-delimited wire types are implemented natively in Zig without external protobuf runtime dependencies.
- **Embedded Asset Virtualization**: The companion app extracts required hotfix manifests and version indices from APK assets to the application data directory at runtime, allowing the internal HTTP server to satisfy the game's CDN requirements offline.
