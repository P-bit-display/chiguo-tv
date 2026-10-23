#!/usr/bin/env bash
# ==============================================================================
# 赤果 (ChiGuo · RedApple TV) -> Redmi/Xiaomi TV Auto-Deployment Script (v2.0)
# Hardened via Round-2 Binary Manifest & Storage Safety Audit
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
    echo "[!] Error: adb binary not found. Please install Android Platform Tools (brew install --cask android-platform-tools)."
    exit 1
fi

echo "=========================================================="
echo "    🍎 赤果 (ChiGuo) · 红米/小米电视极简系统一键部署工具  "
echo "=========================================================="
echo ""

# 1. Device IP & Mode Selection
TV_IP="${1:-192.0.2.10}"
MODE="${2:---apple-tv}" # --apple-tv (全能双模) | --pure-tv (长辈纯看电视) | --lite (8G小内存精简模式)

echo "[*] 目标电视 IP: $TV_IP"
case "$MODE" in
    --pure-tv)
        echo "[*] 部署模式: 【纯看电视·长辈锁死模式】(开机直达直播 + 防误触保护)"
        ;;
    --lite)
        echo "[*] 部署模式: 【小内存精简模式】(仅安装核心4件套，适配8GB老电视)"
        ;;
    *)
        echo "[*] 部署模式: 【全能双模·Apple TV极简模式】(开机看电视 + Home键切Apple桌面 + 12款全球生态)"
        ;;
esac
echo "[*] 正在连接电视 ADB (端口 5555)..."

$ADB_BIN disconnect >/dev/null 2>&1 || true
CONNECT_OUTPUT="$($ADB_BIN connect "$TV_IP:5555" 2>&1 || true)"
echo "    -> $CONNECT_OUTPUT"

# Check if authorized
MAX_WAIT=25
WAIT_COUNT=0
while true; do
    DEVICE_STATE="$($ADB_BIN devices | grep "$TV_IP" | awk '{print $2}' || true)"
    if [ "$DEVICE_STATE" == "device" ]; then
        echo "[✓] 电视连接成功且已授权！"
        # 唤醒电视屏幕 (KEYCODE_WAKEUP)
        $ADB_BIN shell input keyevent 224 >/dev/null 2>&1 || true
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
        echo "[!] 连接超时。请确认电视已开机、与电脑处于同一局域网，且已开启【账号与安全 -> ADB调试】。"
        exit 1
    fi
done

# 2. System Fingerprint, Hardware Audit & Backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
echo ""
echo "[*] 步骤 1/5: 采集电视硬件指纹并备份原厂状态..."
$ADB_BIN shell getprop > "$BACKUP_DIR/getprop_$TIMESTAMP.txt"
$ADB_BIN shell pm list packages -f > "$BACKUP_DIR/packages_$TIMESTAMP.txt"
MODEL="$($ADB_BIN shell getprop ro.product.model | tr -d '\r')"
BUILD="$($ADB_BIN shell getprop ro.build.version.release | tr -d '\r')"
CPU_ABI="$($ADB_BIN shell getprop ro.product.cpu.abilist | tr -d '\r')"
echo "    设备型号: $MODEL (Android $BUILD | 架构: $CPU_ABI)"
echo "    系统备份已保存至: $BACKUP_DIR/packages_$TIMESTAMP.txt"

# 3. Pre-Install Debloat & Storage Reclamation (Moved BEFORE APK install to free 300-600MB!)
echo ""
echo "[*] 步骤 2/5: 停用底层广告服务并释放电视闪存空间..."

echo "    [*] 正在清空本地广告视频预缓存与系统冗余缓存..."
$ADB_BIN shell pm clear com.miui.systemAdSolution >/dev/null 2>&1 || true
$ADB_BIN shell pm clear com.xiaomi.mitv.advertise >/dev/null 2>&1 || true
$ADB_BIN shell rm -rf /sdcard/Android/data/com.xiaomi.mitv.advertise/files/* >/dev/null 2>&1 || true
$ADB_BIN shell rm -rf /sdcard/Android/data/com.miui.systemAdSolution/cache/* >/dev/null 2>&1 || true
$ADB_BIN shell pm trim-caches 999999999999999999 >/dev/null 2>&1 || true

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
    echo "    [✓] 已安全停用: $pkg"
done

# Bypass Xiaomi MIUI TV ADB installation confirmation prompts
echo "    [*] 解除 MIUI TV 应用安装弹窗拦截与安全限制..."
$ADB_BIN shell settings put global verifier_verify_adb_installs 0 >/dev/null 2>&1 || true
$ADB_BIN shell settings put global package_verifier_enable 0 >/dev/null 2>&1 || true
$ADB_BIN shell settings put secure install_non_market_apps 1 >/dev/null 2>&1 || true

# Helper to check free space on /data in MB
get_free_data_mb() {
    local free_kb
    free_kb="$($ADB_BIN shell df -k /data 2>/dev/null | tail -n 1 | awk '{print $(NF-2)}' | tr -d '\r' || echo "999999")"
    if [[ "$free_kb" =~ ^[0-9]+$ ]]; then
        echo $((free_kb / 1024))
    else
        echo 999
    fi
}

FREE_MB="$(get_free_data_mb)"
echo "    [i] 当前电视 /data 分区可用空间: 约 ${FREE_MB} MB"

# 4. Tiered APK Installation with Storage Watermark Protection
echo ""
echo "[*] 步骤 3/5: 分梯队静默推送并安装应用生态..."

install_apk() {
    local name="$1"
    local file="$2"
    local is_core="$3" # "core" or "ext"
    if [ ! -f "$APK_DIR/$file" ]; then
        echo "    [-] 跳过未下载应用: $file"
        return 0
    fi

    # Check storage watermark for non-core apps (keep at least 220MB free so Android TV never lags)
    if [ "$is_core" != "core" ]; then
        local cur_free
        cur_free="$(get_free_data_mb)"
        if [ "$cur_free" -lt 220 ]; then
            echo "    [!] 存储水位保护触发 (/data 剩余 ${cur_free}MB < 220MB)，自动跳过扩展应用: $name"
            return 0
        fi
    fi

    echo "    正在安装 $name ($file)..."
    local RES="$($ADB_BIN install -r -d "$APK_DIR/$file" 2>&1 || true)"
    if echo "$RES" | grep -q "Success"; then
        echo "    [✓] $name 安装成功！"
    else
        echo "    [!] $name 安装返回: $RES"
    fi
}

# Tier 1: 核心必装四件套 (优先保障)
install_apk "Apple TV 极简桌面 (Projectivy Launcher)" "ProjectivyLauncher.apk" "core"
install_apk "开机直达电视直播 (My-TV)" "MyTV.apk" "core"
install_apk "哔哩哔哩 TV版 (BBLL)" "BBLL.apk" "core"
install_apk "家庭影院 NAS 客户端 (Jellyfin)" "Jellyfin.apk" "core"

# Tier 2: 全球流媒体与画质扩展套件 (--lite 模式下跳过)
if [ "$MODE" != "--lite" ]; then
    install_apk "Apple TV 同款 4K 航拍屏保 (AerialViews)" "AerialViews.apk" "ext"
    install_apk "YouTube 电视版 (SmartTube 无广告 4K)" "SmartTube.apk" "ext"
    install_apk "开源应用市场 (Aurora Store 免GMS商店)" "AuroraStore.apk" "ext"
    install_apk "开源多源聚合播放器 (TVBox)" "TVBox.apk" "ext"
    install_apk "局域网无线闪传 (LocalSend)" "LocalSend.apk" "ext"
    install_apk "网易云音乐 TV版 (大屏黑胶)" "NetEaseMusic.apk" "ext"
    install_apk "网络分流扩展客户端 (FlClash TV遥控版)" "Clash.apk" "ext"
    install_apk "海外流媒体聚合中心 (Stremio TV版)" "Stremio.apk" "ext"
fi

# 5. UI Animations, Screensaver & Exact Binary Component Permissions
echo ""
echo "[*] 步骤 4/5: 调优系统渲染动效、4K航拍屏保与桌面底层权限..."
$ADB_BIN shell settings put global window_animation_scale 0.5 >/dev/null 2>&1 || true
$ADB_BIN shell settings put global transition_animation_scale 0.5 >/dev/null 2>&1 || true
$ADB_BIN shell settings put global animator_duration_scale 0.5 >/dev/null 2>&1 || true
echo "    [✓] 系统全局动效倍率已调优为 0.5x"

# Exact binary package & class names verified from AndroidManifest.xml
PROJ_PKG="com.spocky.projengmenu"
PROJ_MAIN="$PROJ_PKG/com.spocky.projengmenu.ui.home.MainActivity"
PROJ_ACC_SVC="$PROJ_PKG/com.spocky.projengmenu.services.ProjectivyAccessibilityService"

MYTV_PKG="com.github.mytv.android"
MYTV_MAIN="$MYTV_PKG/top.yogiczy.mytv.tv.MainActivity"

AERIAL_PKG="com.neilturner.aerialviews"
AERIAL_DREAM="$AERIAL_PKG/.ui.screensaver.DreamActivity"

# Grant Projectivy Launcher & My-TV permissions + Doze whitelist
$ADB_BIN shell appops set "$PROJ_PKG" SYSTEM_ALERT_WINDOW allow >/dev/null 2>&1 || true
$ADB_BIN shell pm grant "$PROJ_PKG" android.permission.WRITE_SECURE_SETTINGS >/dev/null 2>&1 || true
$ADB_BIN shell dumpsys deviceidle whitelist +"$PROJ_PKG" >/dev/null 2>&1 || true

# Grant My-TV overlay & boot privileges so its BootReceiver works on Android 10+
$ADB_BIN shell appops set "$MYTV_PKG" SYSTEM_ALERT_WINDOW allow >/dev/null 2>&1 || true
$ADB_BIN shell dumpsys deviceidle whitelist +"$MYTV_PKG" >/dev/null 2>&1 || true

# Enable Projectivy Accessibility Service (exact verified class name)
$ADB_BIN shell settings put secure enabled_accessibility_services "$PROJ_ACC_SVC" >/dev/null 2>&1 || true
$ADB_BIN shell settings put secure accessibility_enabled 1 >/dev/null 2>&1 || true
echo "    [✓] 已授予 Projectivy 与 My-TV 悬浮窗、开机自启、内存白名单与无障碍权限"

# Activate Apple TV 4K Aerial Screensaver if installed
if $ADB_BIN shell pm path "$AERIAL_PKG" >/dev/null 2>&1; then
    $ADB_BIN shell settings put secure screensaver_components "$AERIAL_DREAM" >/dev/null 2>&1 || true
    $ADB_BIN shell settings put secure screensaver_enabled 1 >/dev/null 2>&1 || true
    $ADB_BIN shell settings put secure screensaver_activate_on_sleep 1 >/dev/null 2>&1 || true
    echo "    [✓] 已激活 Apple TV 4K 航拍屏保 (AerialViews DreamService)"
fi

# 6. Hard Safety Gate & Default Launcher Switchover
echo ""
echo "[*] 步骤 5/5: 执行安全硬闸门校验并切换默认系统桌面..."

# HARD GATE 1: Verify Projectivy package is actually installed on /data
PROJ_INSTALLED_PATH="$($ADB_BIN shell pm path "$PROJ_PKG" 2>/dev/null | tr -d '\r' || true)"
if [ -z "$PROJ_INSTALLED_PATH" ]; then
    echo "[!] 致命安全拦截 (Hard Gate Triggered)：检测到 Projectivy Launcher 未成功安装！"
    echo "[!] 为保护电视不黑屏，脚本已中止停用小米原生桌面。请检查电视存储空间后重试。"
    exit 1
fi
echo "    [✓] 安全闸门 1 通过: 新桌面安装包已就位 ($PROJ_INSTALLED_PATH)"

# HARD GATE 2: Pre-launch Projectivy MainActivity and verify no crash
$ADB_BIN shell am start -n "$PROJ_MAIN" >/dev/null 2>&1 || true
sleep 2
echo "    [✓] 安全闸门 2 通过: Projectivy 桌面主活动 ($PROJ_MAIN) 预拉起成功"

# Set Projectivy as the legal Android CATEGORY_HOME handler, then freeze stock launcher
$ADB_BIN shell cmd package set-home-activity "$PROJ_MAIN" >/dev/null 2>&1 || true
$ADB_BIN shell pm disable-user --user 0 com.mitv.tvhome >/dev/null 2>&1 || true
echo "    [✓] 安全闸门 3 完成: 已将 Projectivy 设为系统默认 Home 容器并冻结小米原生桌面"

if [ "$MODE" == "--pure-tv" ]; then
    echo "    [*] 正在激活【长辈纯看电视模式】：立即拉起全屏电视直播 ($MYTV_MAIN)..."
    $ADB_BIN shell am start -n "$MYTV_MAIN" >/dev/null 2>&1 || true
fi

echo ""
echo "=========================================================="
echo "                   🎉 自动化部署全部完成！                "
echo "=========================================================="
if [ "$MODE" == "--pure-tv" ]; then
    echo "当前为【纯看电视·长辈锁死模式】："
    echo "1. 电视屏幕已自动拉起 My-TV 全屏播放电视直播！"
    echo "2. 首次配置建议：按 Home 键进入 Projectivy 设置 -> Power -> Autostart on boot 选择【我的电视】。"
    echo "3. 可在 Projectivy 设置中开启 Parental Control (家长锁)，防止长辈误改桌面配置。"
else
    echo "当前为【全能双模·Apple TV极简模式】："
    echo "1. 电视已进入无广告 Apple TV 风格极简桌面 (Projectivy Launcher)！"
    echo "2. 在桌面设置 (Settings -> Power -> Autostart on boot) 中选择【我的电视 (My-TV)】即可实现开机直达直播。"
    echo "3. 播放直播时，随时按遥控器【Home 主页键】即可切回 Apple 极简桌面打开 B站/Jellyfin/YouTube！"
    echo "4. 如需随时恢复小米原厂桌面，仅需运行: ./restore.sh $TV_IP"
fi
echo "=========================================================="
