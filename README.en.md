# 🍎 ChiGuo · RedApple TV

[简体中文](README.md) · **English**

A toolkit for configuring Projectivy and media apps on Redmi/Xiaomi Android TVs through local ADB. Root and firmware flashing are not required. Back up device settings before applying changes.

## Verified through 2026-10-24

Test device: MiTV-MFTP0, Android 9 / API 28, firmware 6129.

- Jellyfin sign-in completed through Quick Connect; the user confirmed playback.
- Repaired BBLL 1.5.5 (`com.V2.blb5`) worked. MyTV retaining a hardware decoder caused a separate black-screen issue that cleared after exiting MyTV.
- The default three-entry TVBox configuration played a public archive video. Both larger configurations loaded catalogs: 153 family sites and 49 backup sites. One sampled title failed to play; catalog loading does not establish playback availability.
- The local playlist now contains 112 channels after removing three HTTP 404 sources confirmed on both the computer and TV. One sampled live channel rendered video; the rest were checked for HLS manifest availability only.
- Firmware still disables ADB and may reset Projectivy accessibility. AccessibilityManager 10.3 restored a simulated removal in about 0.5 seconds while preserving voice services. Bindings were healthy after one real reboot; daemon boot startup still needs final verification.
- Disabling MyTV `videoPlayerSkipMultipleFramesOnSameVSync` resolved the short live-TV loop, confirmed by the user.
- NetEase Filmly TV 2.6.23 was installed and connected; the user confirmed both picture and sound. Other players were stopped for the comparison.
- AerialViews manual preview now renders video with TextureView enabled, H.264 1080p and tunneling disabled. Automatic idle activation remains unverified.

See the [detailed device report](docs/调试记录-2026-10-23.md) and [TVBox import instructions](tvbox/README.md) in Chinese. Older design documents and translations describe plans and should not be treated as verified behavior.

## Usage

Requires Bash, curl, ADB, and Python 3 for discovery. Supply your own TV address explicitly:

```bash
./tv_helper.sh <TV_IP> status
./tv_helper.sh <TV_IP> screenshot
./tv_helper.sh <TV_IP> nas <YOUR_JELLYFIN_URL>
./tv_helper.sh <TV_IP> repair-launcher
```

`repair-launcher` preserves existing accessibility services and verifies the current binding. It requires ADB and does not persist authorization across reboot.

For TVBox, open **Settings → Configuration address dialog** first, then run:

```bash
./tv_helper.sh <TV_IP> push-tvbox 'clan://localhost/Download/ChiGuoTVBox_20261023/config-simple.json'
```

This command uses TVBox's HTTP service without ADB. An HTTP `ok` only confirms submission. Check both address fields and select **Confirm** on the TV to save. Import the files and plugins described in [tvbox/README.md](tvbox/README.md) first.

## Initial deployment and rollback

```bash
./deploy.sh <TV_IP> --lite
./deploy.sh <TV_IP> --apple-tv
./restore.sh <TV_IP>
```

Deployment installs apps, changes system settings and switches the launcher. Do not rerun it merely to update an already tuned TV. `--pure-tv` opens MyTV at the end of deployment; it does not guarantee boot-to-live-TV or kiosk locking.

Bundled APKs are historical snapshots. The local BBLL APK now matches the repaired 1.5.5 client used on the TV; its SHA-256 is recorded in `apks/BBLL.version.json`. Deployment skips it if `com.V2.blb5` is already installed. Accounts and content sources need separate configuration.

Rollback restores the stock launcher and selected settings, preserving other accessibility services. It is not a factory reset or a full restoration of saved values. `--uninstall-all` attempts removal of listed apps and does not delete every local configuration.

Discovery requires `CHIGUO_SCAN_PREFIX` set to the first three octets of your own subnet; the project has no built-in home network addresses. `192.0.2.0/24` in historical examples is reserved documentation space.

Personal screenshots, device backups, credentials and local plugin caches must not be committed. [MIT](LICENSE) covers project code; third-party apps, sources and plugins retain their own terms. No universal playback, quality or firmware compatibility is guaranteed.

Build the verified local bundle with Python 3.9+: `python3 tools/prepare_tvbox.py --output tvbox/build`. Downloads are pinned and SHA256 checked; generated files and third-party JARs are excluded from Git. See the Chinese TVBox guide for installation and limitations.

See the [2026-10-24 report](docs/调试记录-2026-10-24.md) for permissions and verification limits. Disable or uninstall AccessibilityManager before running `restore.sh`, since its guard can re-enable Projectivy.
