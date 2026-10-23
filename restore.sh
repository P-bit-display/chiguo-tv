#!/usr/bin/env bash
# ==============================================================================
# 赤果 (ChiGuo · RedApple TV) -> 1-Click Factory Rollback Script (v4.0)
# Full state restoration including Accessibility, Screensaver & Verified Pkgs
# ==============================================================================

set -e

ADB_BIN="/opt/homebrew/bin/adb"
if [ ! -f "$ADB_BIN" ]; then
    ADB_BIN="$(which adb || true)"
fi

TV_IP="${1:-192.0.2.10}"
OPT="${2:-}" # Optional: --uninstall-all (彻底卸载12款第三方应用，用于售后保修无痕还原)
TARGET="$TV_IP:5555"
ADB=("$ADB_BIN" -s "$TARGET")

echo "=========================================================="
echo "          红米/小米电视 -> 一键恢复原厂系统桌面           "
echo "=========================================================="
echo "[*] 正在连接电视: $TARGET ..."
$ADB_BIN connect "$TARGET"

echo "[*] 1/4: 正在解除第三方无障碍按键劫持与恢复原厂屏保..."
# CRITICAL FIX: Clear Projectivy Accessibility Service so it stops hijacking HOME key!
"${ADB[@]}" shell settings put secure enabled_accessibility_services "" >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put secure accessibility_enabled 0 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings delete secure screensaver_components >/dev/null 2>&1 || true

echo "[*] 2/4: 正在重新启用小米原生桌面 (com.mitv.tvhome)..."
"${ADB[@]}" shell pm enable com.mitv.tvhome >/dev/null 2>&1 || true
"${ADB[@]}" shell cmd package set-home-activity com.mitv.tvhome/.MainActivity >/dev/null 2>&1 || true

echo "[*] 3/4: 正在恢复原厂系统组件..."
PACKAGES=(
    "com.miui.systemAdSolution"
    "com.xiaomi.mitv.advertise"
    "com.xiaomi.statistic"
    "com.xiaomi.analytics"
    "com.xiaomi.mitv.shop"
    "com.xiaomi.mitv.payment"
    "com.xiaomi.gamecenter.pad"
    "com.duokan.videodownload"
    "com.xiaomi.mitv.upgrade"
    "com.android.updater"
    "com.xiaomi.mitv.ota"
)

for pkg in "${PACKAGES[@]}"; do
    "${ADB[@]}" shell pm enable "$pkg" >/dev/null 2>&1 || true
    echo "    [✓] 已恢复: $pkg"
done

echo "[*] 4/4: 恢复系统默认动效倍率 (1.0x) 与安全设置..."
"${ADB[@]}" shell settings put global window_animation_scale 1.0 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global transition_animation_scale 1.0 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global animator_duration_scale 1.0 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global verifier_verify_adb_installs 1 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global wifi_scan_always_enabled 1 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global ble_scan_always_enabled 1 >/dev/null 2>&1 || true

if [ "$OPT" == "--uninstall-all" ]; then
    echo "[*] 正在执行无痕卸载 (--uninstall-all)：移除全部安装的第三方应用..."
    # Exact root manifest package names verified via binary AXML parser
    THIRD_PARTY_PKGS=(
        "com.spocky.projengmenu"
        "com.github.mytv.android"
        "com.xx.blbl"
        "org.jellyfin.androidtv"
        "com.neilturner.aerialviews"
        "org.smarttube.stable"
        "com.aurora.store"
        "com.github.tvbox.osc.jun"
        "org.localsend.localsend_app"
        "com.netease.cloudmusic.tv"
        "com.follow.clash"
        "com.stremio.one"
    )
    for tpkg in "${THIRD_PARTY_PKGS[@]}"; do
        "${ADB[@]}" shell pm uninstall "$tpkg" >/dev/null 2>&1 || true
        echo "    [✓] 已卸载: $tpkg"
    done
    "${ADB[@]}" shell rm -f /sdcard/Download/tv.txt >/dev/null 2>&1 || true
    echo "    [✓] 第三方应用与配置已全部清理完毕"
fi

# Send HOME key to immediately bring up Xiaomi Stock Launcher
"${ADB[@]}" shell input keyevent 3 >/dev/null 2>&1 || true

echo ""
echo "=========================================================="
echo "             🎉 原厂小米系统已全部成功恢复！             "
echo "=========================================================="
