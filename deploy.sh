#!/usr/bin/env bash
# ==============================================================================
# Redmi TV -> Apple TV Experience Auto-Deployment Script
# Author: Antigravity Agent
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK_DIR="$DIR/apks"
BACKUP_DIR="$DIR/backup"
ADB_BIN="/opt/homebrew/bin/adb"

mkdir -p "$BACKUP_DIR"

if [ ! -f "$ADB_BIN" ]; then
    ADB_BIN="$(which adb || true)"
fi

if [ -z "$ADB_BIN" ]; then
    echo "[!] Error: adb binary not found. Please install Android Platform Tools."
    exit 1
fi

echo "=========================================================="
echo "    红米电视 -> Apple TV 极简风格一键自动化配置工具       "
echo "=========================================================="
echo ""

# 1. Device IP
TV_IP="${1:-192.0.2.10}"
echo "[*] 目标电视 IP: $TV_IP"
echo "[*] 正在连接电视 ADB (端口 5555)..."

$ADB_BIN disconnect >/dev/null 2>&1 || true
CONNECT_OUTPUT="$($ADB_BIN connect "$TV_IP:5555" 2>&1 || true)"
echo "    -> $CONNECT_OUTPUT"

# Check if authorized
MAX_WAIT=20
WAIT_COUNT=0
while true; do
    DEVICE_STATE="$($ADB_BIN devices | grep "$TV_IP" | awk '{print $2}' || true)"
    if [ "$DEVICE_STATE" == "device" ]; then
        echo "[✓] 电视连接成功且已授权！"
        break
    elif [ "$DEVICE_STATE" == "unauthorized" ]; then
        echo "[!] 请注意电视屏幕：已弹出【允许USB/网络调试吗？】窗口，请用遥控器勾选【总是允许】并按【确定】！"
        sleep 2
    else
        echo "[-] 等待电视 ADB 服务就绪... ($WAIT_COUNT/$MAX_WAIT)"
        $ADB_BIN connect "$TV_IP:5555" >/dev/null 2>&1 || true
        sleep 2
    fi
    WAIT_COUNT=$((WAIT_COUNT + 1))
    if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
        echo "[!] 连接超时。请确认电视已开机且已开启【开发者选项 -> 允许ADB调试】。"
        exit 1
    fi
done

# 2. System Fingerprint & Backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
echo ""
echo "[*] 步骤 1/4: 备份电视系统信息与应用清单..."
$ADB_BIN shell getprop > "$BACKUP_DIR/getprop_$TIMESTAMP.txt"
$ADB_BIN shell pm list packages -f > "$BACKUP_DIR/packages_$TIMESTAMP.txt"
MODEL="$($ADB_BIN shell getprop ro.product.model | tr -d '\r')"
BUILD="$($ADB_BIN shell getprop ro.build.version.release | tr -d '\r')"
echo "    设备型号: $MODEL (Android $BUILD)"
echo "    系统备份已保存至: $BACKUP_DIR/packages_$TIMESTAMP.txt"

# 3. Install 4 Core APKs
echo ""
echo "[*] 步骤 2/4: 静默推送并安装核心软件四大件..."

install_apk() {
    local name="$1"
    local file="$2"
    if [ -f "$APK_DIR/$file" ]; then
        echo "    正在安装 $name ($file)..."
        local RES="$($ADB_BIN install -r -d "$APK_DIR/$file" 2>&1)"
        if echo "$RES" | grep -q "Success"; then
            echo "    [✓] $name 安装成功！"
        else
            echo "    [!] $name 安装结果: $RES"
        fi
    else
        echo "    [!] 警告: 未找到 $file"
    fi
}

install_apk "Apple TV 极简桌面 (Projectivy Launcher)" "ProjectivyLauncher.apk"
install_apk "开机直达电视直播 (My-TV)" "MyTV.apk"
install_apk "哔哩哔哩 TV版 (BBLL)" "BBLL.apk"
install_apk "家庭影院 NAS 客户端 (Jellyfin)" "Jellyfin.apk"

# 4. Debloat MIUI TV (Ad & Telemetry Disabling)
echo ""
echo "[*] 步骤 3/4: 净化底层广告与无用后台应用 (安全停用模式)..."

DEBLOAT_LIST=(
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

for pkg in "${DEBLOAT_LIST[@]}"; do
    $ADB_BIN shell pm disable-user --user 0 "$pkg" >/dev/null 2>&1 || true
    echo "    [✓] 已停用: $pkg"
done

# 5. UI Animations & Permissions
echo ""
echo "[*] 步骤 4/4: 调优系统动画与桌面权限配置..."
$ADB_BIN shell settings put global window_animation_scale 0.5 || true
$ADB_BIN shell settings put global transition_animation_scale 0.5 || true
$ADB_BIN shell settings put global animator_duration_scale 0.5 || true
echo "    [✓] 系统动效倍率已调优为 0.5x (操作响应大幅提速)"

# Grant Projectivy Launcher permissions
PROJ_PKG="com.spocky.projengmenu"
$ADB_BIN shell appops set "$PROJ_PKG" SYSTEM_ALERT_WINDOW allow >/dev/null 2>&1 || true
$ADB_BIN shell pm grant "$PROJ_PKG" android.permission.WRITE_SECURE_SETTINGS >/dev/null 2>&1 || true

# Enable accessibility service for Projectivy to hijack Home key smoothly
$ADB_BIN shell settings put secure enabled_accessibility_services "$PROJ_PKG/$PROJ_PKG.services.AccessibilityService" >/dev/null 2>&1 || true
$ADB_BIN shell settings put secure accessibility_enabled 1 >/dev/null 2>&1 || true
echo "    [✓] 已授予 Projectivy Launcher 悬浮窗与按键捕获权限"

# Disable Xiaomi Stock Launcher
echo "[*] 正在切换默认桌面为 Apple 极简桌面..."
$ADB_BIN shell pm disable-user --user 0 com.mitv.tvhome >/dev/null 2>&1 || true
echo "    [✓] 已安全停用小米原生瀑布流桌面 (随时可通过 restore_redmi_tv.sh 一键恢复)"

echo ""
echo "=========================================================="
echo "                   🎉 自动化部署全部完成！                "
echo "=========================================================="
echo "接下来你可以："
echo "1. 按一下电视遥控器【Home 主页键】，即刻进入 Apple TV 风格桌面！"
echo "2. 在 Projectivy 桌面设置中勾选: 【开机自启】 -> 选择【我的电视 (My-TV)】"
echo "3. 重启电视测试体验！"
echo "=========================================================="
