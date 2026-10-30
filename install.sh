#!/usr/bin/env bash
# ==============================================================================
# 赤果 (ChiGuo) · 终端单行一键安装脚本 (支持 macOS / Linux)
# 用法: curl -fsSL https://raw.githubusercontent.com/P-bit-display/chiguo-tv/main/install.sh | bash
# ==============================================================================

set -e

DIR="$(pwd)/chiguo-tv-installer"
echo "=========================================================="
echo "    🍎 赤果 (ChiGuo · RedApple TV) 极简电视改装安装程序"
echo "=========================================================="
echo ""

# 1. 检查或自动下载 ADB
ADB_BIN="$(which adb || true)"
if [ -z "$ADB_BIN" ] && [ -f "/opt/homebrew/bin/adb" ]; then
    ADB_BIN="/opt/homebrew/bin/adb"
fi

if [ -z "$ADB_BIN" ]; then
    echo "[*] 未检测到系统 ADB，正在从 Google 官方服务器临时下载 platform-tools..."
    mkdir -p "$DIR/bin"
    OS_TYPE="$(uname -s)"
    if [ "$OS_TYPE" == "Darwin" ]; then
        curl -fsSL https://dl.google.com/android/repository/platform-tools-latest-darwin.zip -o "$DIR/bin/adb.zip"
    else
        curl -fsSL https://dl.google.com/android/repository/platform-tools-latest-linux.zip -o "$DIR/bin/adb.zip"
    fi
    unzip -q -o "$DIR/bin/adb.zip" -d "$DIR/bin"
    chmod +x "$DIR/bin/platform-tools/adb"
    ADB_BIN="$DIR/bin/platform-tools/adb"
    rm -f "$DIR/bin/adb.zip"
    echo "[√] ADB 下载就绪！"
fi

# 2. 询问电视 IP
read -p "请输入电视 IP 地址 (如 192.168.50.41): " TV_IP
if [ -z "$TV_IP" ]; then
    echo "[!] 电视 IP 不能为空。"
    exit 1
fi

TARGET="$TV_IP:5555"
echo "[*] 正在连接电视 $TARGET ..."
"$ADB_BIN" connect "$TARGET"
"$ADB_BIN" -s "$TARGET" wait-for-device

echo "[*] 正在执行系统性能优化与去广告..."
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.miui.analytics >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.miui.tv.analytics >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.xiaomi.statistic >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.xm.webcontent >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.xiaomi.mitv.tvpush.tvpushservice >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.mitv.screensaver >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.xiaomi.mibox.lockscreen >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.cmgame.gamehall.xmtv >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.xiaomi.mitv.shoplugin >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.xiaomi.mitv.appstore >/dev/null 2>&1 || true
"$ADB_BIN" -s "$TARGET" shell pm disable-user --user 0 com.xiaomi.mitv.upgrade >/dev/null 2>&1 || true

"$ADB_BIN" -s "$TARGET" shell settings put global window_animation_scale 0.5
"$ADB_BIN" -s "$TARGET" shell settings put global transition_animation_scale 0.5
"$ADB_BIN" -s "$TARGET" shell settings put global animator_duration_scale 0.5
"$ADB_BIN" -s "$TARGET" shell settings put global stay_on_while_plugged_in 3
"$ADB_BIN" -s "$TARGET" shell settings put system screen_off_timeout 2147483647
"$ADB_BIN" -s "$TARGET" shell settings put global hdmi_control_auto_shutdown 0
"$ADB_BIN" -s "$TARGET" shell settings put global auto_update_system 0

echo "=========================================================="
echo " [√] 电视已成功完成极简去广告与性能加速！"
echo " 完整 APK 套件安装建议克隆本仓库后运行: ./一键安装.command"
echo "=========================================================="
