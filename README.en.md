# 🍎 ChiGuo (RedApple TV)

<p align="center">
  <img src="https://img.shields.io/badge/Project-ChiGuo%20RedApple-red?style=for-the-badge" alt="Project">
  <img src="https://img.shields.io/badge/Style-Apple%20tvOS%20Aesthetics-black?style=for-the-badge&logo=apple" alt="Apple tvOS">
  <img src="https://img.shields.io/badge/Platform-Android%20TV%20%7C%20MIUI%20TV%20%7C%20HyperOS-blue?style=for-the-badge&logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/Driven%20by-AI%20Agent-purple?style=for-the-badge&logo=openai" alt="AI Agent">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

<p align="center">
  <b>English</b> · <a href="README.md">简体中文</a>
</p>

<p align="center">
  <b>Transform Redmi & Xiaomi Smart TVs into an Apple tvOS-style Minimalist Experience</b><br>
  <i>Redmi (Red) + Apple = ChiGuo (赤果) · Pure, fast, and bloat-free</i>
</p>

---

## 📖 Introduction

**ChiGuo (赤果)** is an open-source, automated tuning suite for Android TV, Xiaomi TV, and Redmi TV devices. Without root, bootloader unlocking, or bricking risks, it leverages **AI Agents + local Wi-Fi ADB** to deeply debloat stock bloatware and background telemetry, deploy an **Apple tvOS-styled minimal launcher**, and seamlessly integrate **instant boot-to-live-TV, 4K Bilibili, Synology NAS media libraries, SmartTube, and TV-optimized network routing**.

> 💡 **Core Mission**: Modern smart TVs are heavily cluttered with boot advertisements, commercial video waterfalls, and background analytics. Elderly family members often struggle to find standard TV channels. ChiGuo restores the original essence of television: **instant viewing, zero clutter, and pure simplicity**.

---

## 🔍 Key Features

- ⚡ **Instant Boot to Live TV**: Boots straight into full-screen Live TV (CCTV / HD satellite channels) with zero startup ads. Elderly family members can switch channels seamlessly using the remote's up/down or number buttons.
- 🍏 **Apple tvOS Minimal Aesthetics**: Powered by the battle-tested Projectivy Launcher featuring large rounded dynamic cards, frosted-glass backdrop blur, and instant Home-key access to a clean dock.
- 🍃 **Deep Debloat & Offline Ad Purge**: Disables 9 stock advertising, telemetry, and storefront services. Physically clears the hidden `/sdcard` offline ad video cache so ads never replay even when offline. Frees up 40%–60% RAM.
- 🍿 **Full-Stack Media Ecosystem**:
  - **Bilibili TV (BBLL)**: Supports up to 4K 120Hz, Dolby Vision, and silky-smooth danmaku.
  - **Private Home Cinema (Jellyfin)**: Direct LAN connection to Synology NAS media libraries with automated movie poster scraping and hardware VPU acceleration.
  - **SmartTube (YouTube for TV)**: 4K/8K 60fps HDR playback, SponsorBlock integration, zero ad interruptions, and no Google Play Services dependency.
  - **FlClash (TV-Optimized Proxy Client)**: 100% remote D-pad navigation support for rule-based routing (direct LAN/domestic streams, proxy for overseas media).
  - **TVBox Aggregator**: Ultra-lightweight open-source player core supporting customizable external endpoints.
  - **Apple TV 4K Aerial Screensaver (AerialViews)**: High-resolution slow-motion 4K aerial screensavers (ISS earth orbit, global landmarks) during idle standby.
  - **NetEase Cloud Music TV**: Vinyl record player UI for living room ambiance.
  - **LocalSend**: Cross-platform wireless LAN file/APK transfer from Mac, PC, or mobile without USB flash drives.
- 🛡️ **10-Round Red/Blue Team Hardening**: Includes pre-flight health checks to prevent soft-bricks, memory-killer (Anti-LMK) immunity white-listing, and 100% preservation of XiaoAI voice button and HDMI-CEC input switching.
- 🔄 **One-Click Reversible**: Includes a `restore.sh` rollback script that reinstates all stock components and the original Xiaomi launcher in 3 seconds.

---

## 🆚 ChiGuo vs CleanYourTV

| Dimension | CleanYourTV (Upstream Project) | ChiGuo (This Project) |
| :--- | :--- | :--- |
| **Target Ecosystem** | US/European streaming only (Netflix, Prime, YouTube) | **Dual Global & Domestic Ecosystem** (Live TV, Bilibili 4K, Synology NAS, SmartTube, Clash) |
| **Instant Live TV Boot** | ❌ Not supported (only boots to launcher) | ✅ **Natively supported** (boots directly to Live TV for elders; Home key returns to Apple UI) |
| **Launcher Maturity** | Custom minimalist launcher (modifications require recompilation) | **Projectivy Launcher (tvOS Edition)** (dynamic blur, auto-start engine, focus zoom) |
| **Network Proxy Routing**| ❌ No solution provided | ✅ **Integrated FlClash TV** (full D-pad remote navigation) |
| **Ad Purging Depth** | Standard package disabling only | **Package disabling + physical removal of offline ad video cache** |
| **Soft-Brick Protection** | Basic (disables stock launcher directly) | **Pre-flight verification** (tests new launcher execution before switching) |
| **Port Security** | Emphasizes closing port 5555 after completion | **Fully adopted** (guided physical closure of ADB post-deployment) |

---

## 🤖 Method 1: Autonomous Execution with AI Agents

If you use [Claude Code](https://claude.com/product/claude-code), Cursor, Antigravity, or other terminal-capable AI Agents:

1. On your TV: enable **Developer Options → Allow ADB Debugging**.
2. Copy the contents of [`PROMPT.en.md`](PROMPT.en.md) and send it to your AI Agent.
3. The AI Agent will automatically scan your LAN, connect via ADB, backup system state, and complete the deployment unattended.

---

## 🛠️ Method 2: Manual One-Click Deployment (Dual-Mode)

1. Ensure your computer and TV are on the same Wi-Fi / LAN network.
2. Enable **ADB Debugging** on your TV (Settings → About → click OS Version 5 times → Developer Options → Allow ADB Debugging).
3. Run the deployment script from your terminal:

### Option A: All-in-One Dual-Mode (Recommended for Family & Geeks)
```bash
./deploy.sh <TV_IP_ADDRESS>
```
* **Experience**: Boots directly to ad-free Live TV channels. Pressing the remote's **Home** key brings up the sleek Apple tvOS-style launcher for Bilibili, Jellyfin NAS, YouTube, and music.

### Option B: Dedicated TV-Only Kiosk Mode (Elderly Lock-in)
```bash
./deploy.sh <TV_IP_ADDRESS> --pure-tv
```
* **Experience**: **Completely locks the TV into Live Broadcast mode**. Turning on the TV immediately shows live channels. Pressing Home or Back only shows the channel guide and **never exits to any smart launcher or settings menu**.

---

### 🛡️ One-Click Factory Restoration
To restore the stock Xiaomi launcher and re-enable all original system components:
```bash
./restore.sh <TV_IP_ADDRESS>
```

---

## 🗂️ Repository Structure

```
├── apks/                         # 10 core application packages (offline-ready)
│   ├── ProjectivyLauncher.apk    # Apple tvOS minimal launcher
│   ├── MyTV.apk                  # Live TV broadcast player
│   ├── Clash.apk                 # TV-optimized proxy client (FlClash)
│   ├── SmartTube.apk             # Ad-free 4K/8K YouTube client
│   ├── BBLL.apk                  # Bilibili 4K Dolby client
│   ├── Jellyfin.apk              # Home cinema client (Synology NAS)
│   ├── TVBox.apk                 # Lightweight media aggregator
│   ├── NetEaseMusic.apk          # Vinyl record audio player
│   ├── AerialViews.apk           # 4K aerial screensavers
│   └── LocalSend.apk             # Cross-platform LAN file transfer
├── deploy.sh                     # 🚀 Automated deployment script (Dual-mode)
├── restore.sh                    # 🛡️ Instant factory restore script
├── PROMPT.en.md                  # 🤖 AI Agent standard prompt (English)
├── PROMPT.md                     # 🤖 AI Agent standard prompt (Chinese)
├── redmi_tv_apple_system_ultimate_spec.md # Technical architecture specification
├── redmi_tv_red_blue_review.md   # 🔴🔵 10-round adversarial review report
├── redmi_tv_test_cases_and_risks.md       # 14 end-to-end test cases
└── LICENSE                       # MIT License
```

---

## ⚖️ Legal Disclaimer

1. **Research & Educational Purpose**: This project represents technical research and personal device tuning exploration on Android TV systems for educational and personal maintenance purposes only.
2. **Device Ownership & Control**: Users hold lawful ownership and exclusive control over their purchased hardware. This project does not crack bootloaders or tamper with hardware firmware; all operations rely on standard, publicly available Android ADB protocols.
3. **Content & Copyright**: This project does not provide, host, or distribute any copyrighted media streams or pirated services. Third-party applications referenced belong to their respective open-source developers or original copyright holders.
4. **Trademarks**: References to "Xiaomi", "Redmi", "Apple", "Apple TV", "tvOS", and "Bilibili" are used strictly for compatibility descriptions and aesthetic stylistic references. No endorsement or affiliation is implied.
5. **User Responsibility**: Users assume responsibility for complying with applicable local laws, regulations, and hardware terms of service.
