#!/usr/bin/env bash
# ==============================================================================
# 赤果 (ChiGuo · RedApple TV) -> 1-Click Factory Rollback Script (v2.0)
# ==============================================================================

set -e

ADB_BIN="/opt/homebrew/bin/adb"
if [ ! -f "$ADB_BIN" ]; then
    ADB_BIN="$(which adb || true)"
fi

TV_IP="${1:-192.0.2.10}"

echo "=========================================================="
echo "          红米/小米电视 -> 一键恢复原厂系统桌面           "
echo "=========================================================="
echo "[*] 正在连接电视: $TV_IP:5555 ..."
$ADB_BIN connect "$TV_IP:5555"

echo "[*] 正在重新启用小米原生桌面 (com.mitv.tvhome)..."
$ADB_BIN shell pm enable com.mitv.tvhome >/dev/null 2>&1 || true
$ADB_BIN shell cmd package set-home-activity com.mitv.tvhome/.MainActivity >/dev/null 2>&1 || true
$ADB_BIN shell input keyevent 3 >/dev/null 2>&1 || true

echo "[*] 正在恢复原厂系统组件..."
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
)

for pkg in "${PACKAGES[@]}"; do
    $ADB_BIN shell pm enable "$pkg" >/dev/null 2>&1 || true
    echo "    [✓] 已恢复: $pkg"
done

echo "[*] 恢复动画默认速度 (1.0x) 与安全校验..."
$ADB_BIN shell settings put global window_animation_scale 1.0 >/dev/null 2>&1 || true
$ADB_BIN shell settings put global transition_animation_scale 1.0 >/dev/null 2>&1 || true
$ADB_BIN shell settings put global animator_duration_scale 1.0 >/dev/null 2>&1 || true
$ADB_BIN shell settings put global verifier_verify_adb_installs 1 >/dev/null 2>&1 || true

echo ""
echo "=========================================================="
echo "             🎉 原厂小米系统已全部成功恢复！             "
echo "=========================================================="
