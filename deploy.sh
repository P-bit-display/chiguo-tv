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
echo "    🍎 赤果 (ChiGuo) · 红米/小米电视极简系统一键部署工具  "
echo "=========================================================="
echo ""

# 1. Device IP & Mode Selection
TV_IP="${1:-192.0.2.10}"
MODE="${2:---apple-tv}" # --apple-tv (全能双模) or --pure-tv (纯看电视锁死模式)

echo "[*] 目标电视 IP: $TV_IP"
if [ "$MODE" == "--pure-tv" ]; then
    echo "[*] 部署模式: 【纯看电视·长辈锁死模式】(Home键不退出演播，防误触)"
else
    echo "[*] 部署模式: 【全能双模·Apple TV极简模式】(开机看电视 + Home键切Apple桌面)"
fi
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

# 3. Install Core & Extended APKs
echo ""
echo "[*] 步骤 2/4: 静默推送并安装系统与影音生态应用..."

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
        echo "    [-] 跳过未下载应用: $file"
    fi
}

# 基础四件套
install_apk "Apple TV 极简桌面 (Projectivy Launcher)" "ProjectivyLauncher.apk"
install_apk "开机直达电视直播 (My-TV)" "MyTV.apk"
install_apk "哔哩哔哩 TV版 (BBLL)" "BBLL.apk"
install_apk "家庭影院 NAS 客户端 (Jellyfin)" "Jellyfin.apk"

# 进阶与海外流媒体生态
install_apk "科学上网工具 (FlClash TV遥控版)" "Clash.apk"
install_apk "YouTube 电视版 (SmartTube 无广告 4K)" "SmartTube.apk"
install_apk "全网免费影视聚合 (TVBox)" "TVBox.apk"
install_apk "网易云音乐 TV版 (大屏黑胶)" "NetEaseMusic.apk"
install_apk "Apple TV 同款 4K 航拍屏保 (AerialViews)" "AerialViews.apk"
install_apk "局域网无线闪传 (LocalSend)" "LocalSend.apk"

# 4. Debloat MIUI TV (Ad & Telemetry Disabling)
echo ""
echo "[*] 步骤 3/4: 净化底层广告与无用后台应用 (安全停用模式)..."

# 清理开机广告本地预缓存（社区推荐关键步骤，防止断网播放旧缓存广告）
echo "    [*] 清理电视本地广告视频与图片缓存..."
$ADB_BIN shell pm clear com.miui.systemAdSolution >/dev/null 2>&1 || true
$ADB_BIN shell pm clear com.xiaomi.mitv.advertise >/dev/null 2>&1 || true
$ADB_BIN shell rm -rf /sdcard/Android/data/com.xiaomi.mitv.advertise/files/* >/dev/null 2>&1 || true
$ADB_BIN shell rm -rf /sdcard/Android/data/com.miui.systemAdSolution/cache/* >/dev/null 2>&1 || true

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

# Anti-LMK Kill: Add to Doze/Battery whitelist
$ADB_BIN shell dumpsys deviceidle whitelist +"$PROJ_PKG" >/dev/null 2>&1 || true

# Enable accessibility service for Projectivy to hijack Home key smoothly
$ADB_BIN shell settings put secure enabled_accessibility_services "$PROJ_PKG/$PROJ_PKG.services.AccessibilityService" >/dev/null 2>&1 || true
$ADB_BIN shell settings put secure accessibility_enabled 1 >/dev/null 2>&1 || true
echo "    [✓] 已授予 Projectivy Launcher 悬浮窗、内存白名单与按键捕获权限"

# Pre-flight Verification before disabling stock launcher
echo "[*] 正在执行桌面拉起与预检测试..."
$ADB_BIN shell am start -n "$PROJ_PKG/.MainActivity" >/dev/null 2>&1 || true
sleep 1

# Disable Xiaomi Stock Launcher & Set Desired Mode
echo "[*] 正在切换默认桌面..."
if [ "$MODE" == "--pure-tv" ]; then
    MYTV_PKG="com.mytv.android"
    echo "    [*] 配置长辈纯看电视锁死模式: 将 My-TV 设为默认 Home..."
    $ADB_BIN shell cmd package set-home-activity "$MYTV_PKG/.MainActivity" >/dev/null 2>&1 || true
    $ADB_BIN shell pm disable-user --user 0 com.mitv.tvhome >/dev/null 2>&1 || true
    $ADB_BIN shell am start -n "$MYTV_PKG/.MainActivity" >/dev/null 2>&1 || true
    echo "    [✓] 长辈纯看电视锁死模式已就绪！按 Home 键或返回键永不跳出电视！"
else
    echo "    [*] 配置全能双模: 将 Projectivy 设为默认 Home..."
    $ADB_BIN shell cmd package set-home-activity "$PROJ_PKG/.MainActivity" >/dev/null 2>&1 || true
    $ADB_BIN shell pm disable-user --user 0 com.mitv.tvhome >/dev/null 2>&1 || true
    echo "    [✓] Apple TV 极简桌面已就绪！(随时可通过 restore.sh 一键恢复)"
fi

echo ""
echo "=========================================================="
echo "                   🎉 自动化部署全部完成！                "
echo "=========================================================="
if [ "$MODE" == "--pure-tv" ]; then
    echo "当前为【纯看电视·长辈锁死模式】："
    echo "1. 电视屏幕正在全屏播放电视直播！"
    echo "2. 遥控器上下键切台、左右键调音量，按 Home 键永不退出。"
else
    echo "当前为【全能双模·Apple TV极简模式】："
    echo "1. 按一下电视遥控器【Home 主页键】，即刻进入 Apple TV 风格桌面！"
    echo "2. 在 Projectivy 桌面设置中勾选: 【开机自启】 -> 选择【我的电视 (My-TV)】"
    echo "3. 享受无广告开机直达电视直播、Home键随时切桌面的终极体验！"
fi
echo "=========================================================="
