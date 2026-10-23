> 2026-10-23: Read [current device findings](docs/调试记录-2026-10-23.md) first. Do not rerun full deployment on an already tuned TV or claim persistent ADB/accessibility, automatic live boot, or screensaver playback without testing. Preserve existing accessibility services.

# ChiGuo (RedApple TV) · AI Agent Prompt

Copy and paste the prompt below into any terminal-capable AI Assistant (e.g., Claude Code, Cursor, Antigravity, OpenDevin, Gemini CLI):

---

```markdown
Please help me optimize and transform my Android TV / Xiaomi TV / Redmi TV into an Apple tvOS-style minimalist experience, complete with instant Live TV booting for elderly family members and high-definition home cinema.

My network environment and device info:
- TV Brand/Model: Redmi / Xiaomi Smart TV (Android TV / MIUI TV / HyperOS)
- Computer and TV are on the same local network (Wi-Fi or Ethernet)
- Tool repository: https://github.com/P-bit-display/chiguo-tv

Please execute according to the following strict engineering guidelines:
1. Establish Connection:
   - Scan the local network ARP table or port 5555 to locate the TV IP and connect over ADB.
   - If unauthorized, prompt me to accept the ADB debugging authorization dialog on the TV screen.
2. System State Backup:
   - Backup the full package list (`pm list packages -f`) and `getprop` output to the local `backup/` directory before modifying any packages.
3. Deep Ad & Bloatware Purge:
   - Clear the offline advertising video cache pool at `/sdcard/Android/data/com.xiaomi.mitv.advertise/files/*`.
   - Use `pm disable-user --user 0` to disable the 9 stock advertising, telemetry, and storefront services.
   - Never disable XiaoAI voice services (`com.xiaomi.voicecontrol`), Bluetooth drivers, or HDMI input settings.
4. Core Ecosystem Deployment:
   - Install Projectivy Launcher (tvOS style), My-TV (Live broadcast), FlClash (TV proxy), SmartTube (ad-free 4K YouTube), Jellyfin (Synology NAS), BBLL (Bilibili 4K), TVBox, NetEase Music, AerialViews (4K screensaver), and LocalSend.
5. Soft-Brick Verification & Launcher Cutover:
   - Before disabling the stock launcher (`com.mitv.tvhome`), launch the new launcher via `am start` and verify its running state. Only cut over after confirming it is alive.
   - Whitelist Projectivy Launcher against Doze and memory killer (`dumpsys deviceidle whitelist`).
6. Post-Deployment Verification:
   - Guide me through verifying cold boot into Live TV, pressing Home to access the Apple tvOS launcher, and remind me to turn off ADB debugging on the TV when done for port security.
```
