#!/usr/bin/env bash
# ==============================================================================
# 赤果 (ChiGuo · RedApple TV) -> Stock Launcher Rollback Script (v5.0)
# Restore stock launcher and selected settings; not a factory reset
# ==============================================================================

set -e

ADB_BIN="${CHIGUO_ADB_BIN:-/opt/homebrew/bin/adb}"
if [ ! -f "$ADB_BIN" ]; then
    ADB_BIN="$(which adb || true)"
fi

TV_IP="${1:-}"
if [ -z "$TV_IP" ]; then
    echo "用法: ./restore.sh <电视IP> [参数]；请显式指定自己的设备。"
    exit 1
fi
OPT="${2:-}" # Optional: --uninstall-all (彻底卸载12款第三方应用，用于售后保修无痕还原)
TARGET="$TV_IP:5555"
ADB=("$ADB_BIN" -s "$TARGET")

echo "=========================================================="
echo "          红米/小米电视 -> 恢复小米系统桌面           "
echo "=========================================================="
echo "[*] 正在连接电视: $TARGET ..."
$ADB_BIN connect "$TARGET"

echo "[*] 1/4: 正在解除第三方无障碍按键劫持与恢复原厂屏保..."
# Remove only Projectivy; preserve XiaoAI and other accessibility services.
PROJ_SERVICE="com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService"
if ! CURRENT_SERVICES="$("${ADB[@]}" shell settings get secure enabled_accessibility_services)"; then
    echo "[!] 无法读取原有无障碍服务，已停止恢复。"
    exit 1
fi
CURRENT_SERVICES="${CURRENT_SERVICES//$'\r'/}"
REMAINING_SERVICES=""
IFS=':' read -r -a SERVICE_ITEMS <<< "$CURRENT_SERVICES"
for service in "${SERVICE_ITEMS[@]}"; do
    case "$service" in
        ""|null|"$PROJ_SERVICE") continue ;;
    esac
    REMAINING_SERVICES="${REMAINING_SERVICES:+$REMAINING_SERVICES:}$service"
done
if [ -n "$REMAINING_SERVICES" ]; then
    "${ADB[@]}" shell settings put secure enabled_accessibility_services "$REMAINING_SERVICES"
    "${ADB[@]}" shell settings put secure accessibility_enabled 1
else
    "${ADB[@]}" shell settings delete secure enabled_accessibility_services
    "${ADB[@]}" shell settings put secure accessibility_enabled 0
fi
"${ADB[@]}" shell settings delete secure screensaver_components >/dev/null 2>&1 || true

echo "[*] 2/4: 正在重新启用小米原生桌面 (com.mitv.tvhome)..."
"${ADB[@]}" shell pm enable com.mitv.tvhome >/dev/null 2>&1 || true
"${ADB[@]}" shell cmd package set-home-activity com.mitv.tvhome/.MainActivity >/dev/null 2>&1 || true

echo "[*] 3/4: 正在恢复原厂系统组件..."
PACKAGES=(
    "com.miui.systemAdSolution"
    "com.xiaomi.mitv.advertise"
    "com.xiaomi.tv.gallery"
    "com.duokan.videodaily"
    "com.duokan.videodownload"
    "com.xiaomi.mitv.handbook"
    "com.xiaomi.statistic"
    "com.xiaomi.analytics"
    "com.xiaomi.mitv.shop"
    "com.xiaomi.mitv.payment"
    "com.xiaomi.gamecenter.pad"
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
        "com.xx.blbl1"
        "com.V2.blb5"
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
    echo "    [✓] 已尝试卸载所列应用并删除 tv.txt；其他本地配置文件仍保留"
fi

# Send HOME key to immediately bring up Xiaomi Stock Launcher
"${ADB[@]}" shell input keyevent 3 >/dev/null 2>&1 || true

echo ""
echo "=========================================================="
echo "             🎉 已执行桌面与所列设置恢复，请在电视端核对。             "
echo "=========================================================="
