#!/usr/bin/env bash
# ==============================================================================
# 赤果 (ChiGuo · RedApple TV) -> Redmi/Xiaomi TV Auto-Deployment Script (v5.0)
# Hardened via 30-Round Live-Device Telemetry, Port 6095 Auto-Guide & Binary Audit
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK_DIR="$DIR/apks"
BACKUP_DIR="$DIR/backup"
ADB_BIN="${CHIGUO_ADB_BIN:-/opt/homebrew/bin/adb}"

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

# 1. Device IP (Supports 'auto' LAN discovery) & Mode Selection
TV_IP="${1:-}"
if [ -z "$TV_IP" ]; then
    echo "用法: ./deploy.sh <电视IP> [参数]；请显式指定自己的设备。"
    exit 1
fi
MODE="${2:---apple-tv}" # --apple-tv (全能双模) | --pure-tv (长辈纯看电视) | --lite (8G小内存精简模式)

if [ "$TV_IP" == "auto" ]; then
    SCAN_PREFIX="${CHIGUO_SCAN_PREFIX:-}"
    if [ -z "$SCAN_PREFIX" ]; then
        echo "请设置 CHIGUO_SCAN_PREFIX 为自己的网段前三段，或显式指定电视 IP。"
        exit 1
    fi
    echo "[*] 正在自动扫描指定网段内处于开机状态的小米/红米电视..."
    DETECTED_IP="$(python3 -c '
import socket, concurrent.futures, sys, ipaddress
network = ipaddress.ip_network(sys.argv[1] + ".0/24", strict=True)
prefix = str(network.network_address).rsplit(".", 1)[0]
def p(i):
    ip = f"{prefix}.{i}"
    for port in (5555, 6095):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.2)
        if s.connect_ex((ip, port)) == 0:
            s.close()
            return ip
        s.close()
    return None
with concurrent.futures.ThreadPoolExecutor(max_workers=64) as ex:
    res = [r for r in ex.map(p, range(2, 254)) if r]
print(res[0] if res else "")
' "$SCAN_PREFIX")"
    if [ -z "$DETECTED_IP" ]; then
        echo "[!] 未在局域网内发现开机状态的小米/红米电视，请确认电视已开机联网。"
        exit 1
    fi
    TV_IP="$DETECTED_IP"
fi

TARGET="$TV_IP:5555"
ADB=("$ADB_BIN" -s "$TARGET")

# Query TV name via Port 6095 if available
TV_FRIENDLY_NAME="$(curl -s -m 1 "http://$TV_IP:6095/controller?action=getsysteminfo" | sed -n 's/.*"devicename":"\([^"]*\)".*/\1/p' || true)"
echo "[*] 目标电视: $TV_IP ${TV_FRIENDLY_NAME:+($TV_FRIENDLY_NAME)}"
case "$MODE" in
    --pure-tv)
        echo "[*] 部署模式: 【直播启动模式】(部署结束打开直播；重启自启需单独验证)"
        ;;
    --lite)
        echo "[*] 部署模式: 【小内存精简模式】(仅安装核心4件套，适配8GB老电视)"
        ;;
    *)
        echo "[*] 部署模式: 【全能双模·Apple TV极简模式】(Projectivy 桌面与影音应用；不保证重启直达直播)"
        ;;
esac
echo "[*] 正在连接电视 ADB ($TARGET)..."

CONNECT_OUTPUT="$($ADB_BIN connect "$TARGET" 2>&1 || true)"
if echo "$CONNECT_OUTPUT" | grep -q "No route to host"; then
    echo "    [*] 正在重置本地 ADB 守护进程以刷新局域网路由权限..."
    $ADB_BIN kill-server >/dev/null 2>&1 || true
    CONNECT_OUTPUT="$($ADB_BIN connect "$TARGET" 2>&1 || true)"
fi
echo "    -> $CONNECT_OUTPUT"

# Round 30 Auto-Guide: If ADB 5555 is closed (Connection refused) but Port 6095 is open,
# automatically pop open Xiaomi Settings app on TV screen to guide user!
SETTINGS_POPPED=0
MAX_WAIT=120
WAIT_COUNT=0
while true; do
    DEVICE_STATE="$($ADB_BIN devices | awk -v t="$TARGET" '$1 == t {print $2}' || true)"
    if [ "$DEVICE_STATE" == "device" ]; then
        echo "[✓] 电视连接成功且已授权！"
        "${ADB[@]}" shell input keyevent 224 >/dev/null 2>&1 || true
        break
    elif [ "$DEVICE_STATE" == "unauthorized" ]; then
        echo "[!] 请看电视屏幕：已弹出【允许USB/网络调试吗？】窗口，请用遥控器勾选【总是允许】并按【确定】！"
        sleep 2
    else
        if [ $SETTINGS_POPPED -eq 0 ]; then
            if curl -s -m 1 "http://$TV_IP:6095/controller?action=startapp&type=packagename&packagename=com.xiaomi.mitv.settings" >/dev/null 2>&1; then
                echo ""
                echo "💡 [智能引导] 检测到电视尚未开启 ADB 调试，已自动为您在电视屏幕上弹出【系统设置】！"
                echo "   请拿起遥控器按以下 2 步开启（开启后脚本将自动继续，无需重新运行）："
                echo "   1. 进入【关于本机】-> 光标停在【产品型号】上连续按 7 次【确定键】提示进入开发者模式；"
                echo "   2. 返回上一级进入【账号与安全】-> 将【ADB 调试】切换为【允许】。"
                echo ""
                SETTINGS_POPPED=1
            fi
        fi
        echo "[-] 等待电视开启 ADB 调试端口 (5555)... ($WAIT_COUNT/$MAX_WAIT)"
        $ADB_BIN connect "$TARGET" >/dev/null 2>&1 || true
        sleep 3
    fi
    WAIT_COUNT=$((WAIT_COUNT + 1))
    if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
        echo "[!] 等待超时。在电视上开启【账号与安全 -> ADB调试】后，再次运行 ./deploy.sh $TV_IP 即可。"
        exit 1
    fi
done

# Helper to check free space on /data in MB
get_free_data_mb() {
    local free_kb
    free_kb="$("${ADB[@]}" shell df -k /data 2>/dev/null | tail -n 1 | awk '{print $(NF-2)}' | tr -d '\r' || echo "999999")"
    if [[ "$free_kb" =~ ^[0-9]+$ ]]; then
        echo $((free_kb / 1024))
    else
        echo 999
    fi
}

BEFORE_FREE_MB="$(get_free_data_mb)"

# 2. System Fingerprint, Hardware Audit & Per-Device Isolated Backup (Round 24)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
echo ""
echo "[*] 步骤 1/5: 采集电视硬件指纹并建立专属备份档案..."
MODEL="$("${ADB[@]}" shell getprop ro.product.model | tr -d '\r ' || echo "MiTV")"
BUILD="$("${ADB[@]}" shell getprop ro.build.version.release | tr -d '\r')"
SDK_VER="$("${ADB[@]}" shell getprop ro.build.version.sdk | tr -d '\r')"
CPU_ABI="$("${ADB[@]}" shell getprop ro.product.cpu.abilist | tr -d '\r')"
BACKUP_PREFIX="$BACKUP_DIR/${TV_IP}_${MODEL}_$TIMESTAMP"

"${ADB[@]}" shell getprop > "${BACKUP_PREFIX}_getprop.txt"
"${ADB[@]}" shell pm list packages -f > "${BACKUP_PREFIX}_packages.txt"
echo "    设备型号: $MODEL (Android $BUILD / API $SDK_VER | 架构: $CPU_ABI)"
echo "    初始可用闪存 (/data): 约 ${BEFORE_FREE_MB} MB"
echo "    专属备份档案: ${BACKUP_PREFIX}_packages.txt"

# 3. Pre-Install Debloat & Storage Reclamation (Includes Round 21 Live-Device Bloatware!)
echo ""
echo "[*] 步骤 2/5: 停用底层广告、时尚画报与更新服务并释放闪存空间..."

echo "    [*] 正在清空本地广告视频预缓存、OTA残留包与系统冗余缓存..."
"${ADB[@]}" shell pm clear com.miui.systemAdSolution >/dev/null 2>&1 || true
"${ADB[@]}" shell pm clear com.xiaomi.mitv.advertise >/dev/null 2>&1 || true
"${ADB[@]}" shell pm clear com.xiaomi.tv.gallery >/dev/null 2>&1 || true
"${ADB[@]}" shell pm clear com.duokan.videodaily >/dev/null 2>&1 || true
"${ADB[@]}" shell rm -rf /sdcard/Android/data/com.xiaomi.mitv.advertise/files/* >/dev/null 2>&1 || true
"${ADB[@]}" shell rm -rf /sdcard/Android/data/com.miui.systemAdSolution/cache/* >/dev/null 2>&1 || true
"${ADB[@]}" shell rm -rf /sdcard/downloaded_rom/* /sdcard/Download/ota/* >/dev/null 2>&1 || true
"${ADB[@]}" shell pm trim-caches 999999999999999999 >/dev/null 2>&1 || true

# Note: com.xiaomi.voicecontrol (小爱同学), com.xiaomi.mitv.smartshare (无线投屏)
# and com.xiaomi.mitv.settings (设置) are strictly preserved!
DEBLOAT_LIST=(
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

for pkg in "${DEBLOAT_LIST[@]}"; do
    "${ADB[@]}" shell pm disable-user --user 0 "$pkg" >/dev/null 2>&1 || true
    echo "    [✓] 已安全停用: $pkg"
done

# Explicitly safeguard wireless casting (AirPlay/DLNA) and Settings
"${ADB[@]}" shell pm enable com.xiaomi.mitv.smartshare >/dev/null 2>&1 || true
"${ADB[@]}" shell pm enable com.xiaomi.mitv.settings >/dev/null 2>&1 || true

# Bypass Xiaomi MIUI TV ADB installation prompts, set Aliyun NTP & request TCP ADB (firmware may reset it)
echo "    [*] 解除 MIUI TV 安装弹窗拦截、校准阿里云 NTP 授时并请求当前 ADB 设置（重启后可能被固件重置）..."
"${ADB[@]}" shell settings put global verifier_verify_adb_installs 0 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global package_verifier_enable 0 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put secure install_non_market_apps 1 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global auto_update 0 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global ntp_server ntp.aliyun.com >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global adb_enabled 1 >/dev/null 2>&1 || true
"${ADB[@]}" shell setprop persist.adb.tcp.port 5555 >/dev/null 2>&1 || true

FREE_MB="$(get_free_data_mb)"
echo "    [i] 清理后 /data 分区可用空间: 约 ${FREE_MB} MB"

# 4. Tiered APK Installation with Storage Watermark, Auto-Reconnect & Auto-Permission Grant (-g)
echo ""
echo "[*] 步骤 3/5: 分梯队静默推送并安装应用生态 (自动授予运行时权限)..."

install_apk() {
    local name="$1"
    local file="$2"
    local is_core="$3" # "core" or "ext"
    local min_sdk="${4:-17}"
    if [ ! -f "$APK_DIR/$file" ]; then
        echo "    [-] 跳过未下载应用: $file"
        return 0
    fi

    # Preserve the repaired BBLL variant instead of reinstalling the legacy bundle.
    if [ "$file" == "BBLL.apk" ]; then
        if "${ADB[@]}" shell pm path com.V2.blb5 2>/dev/null | grep -q '^package:'; then
            echo "    [i] 已安装修复版 BBLL (com.V2.blb5)，跳过仓库旧版安装包。"
            return 0
        fi
    fi

    # Ensure ADB socket is alive before each transfer (Round 27 Wi-Fi jitter resilience)
    $ADB_BIN connect "$TARGET" >/dev/null 2>&1 || true

    # Check Android SDK version compatibility
    if [[ "$SDK_VER" =~ ^[0-9]+$ ]] && [ "$SDK_VER" -lt "$min_sdk" ]; then
        echo "    [!] 系统版本过低 (当前 API $SDK_VER < 要求 API $min_sdk)，自动跳过: $name"
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
    local RES
    if [[ "$SDK_VER" =~ ^[0-9]+$ ]] && [ "$SDK_VER" -ge 23 ]; then
        RES="$("${ADB[@]}" install -r -d -g "$APK_DIR/$file" 2>&1 || true)"
    else
        RES="$("${ADB[@]}" install -r -d "$APK_DIR/$file" 2>&1 || true)"
    fi

    if echo "$RES" | grep -q "Success"; then
        echo "    [✓] $name 安装成功 (已免除首次运行权限弹窗)！"
    else
        echo "    [!] $name 安装返回: $RES"
    fi
}

# Tier 1: 核心必装四件套 (优先保障)
install_apk "Apple TV 极简桌面 (Projectivy Launcher)" "ProjectivyLauncher.apk" "core" 23
install_apk "开机直达电视直播 (My-TV)" "MyTV.apk" "core" 23
install_apk "哔哩哔哩 TV版 (BBLL)" "BBLL.apk" "core" 21
install_apk "家庭影院 NAS 客户端 (Jellyfin)" "Jellyfin.apk" "core" 21

# Tier 2: 全球流媒体与画质扩展套件 (--lite 模式下跳过)
if [ "$MODE" != "--lite" ]; then
    install_apk "Apple TV 同款 4K 航拍屏保 (AerialViews)" "AerialViews.apk" "ext" 23
    install_apk "YouTube 电视版 (SmartTube 无广告 4K)" "SmartTube.apk" "ext" 17
    install_apk "开源应用市场 (Aurora Store 免GMS商店)" "AuroraStore.apk" "ext" 23
    install_apk "开源多源聚合播放器 (TVBox)" "TVBox.apk" "ext" 19
    install_apk "局域网无线闪传 (LocalSend)" "LocalSend.apk" "ext" 24
    install_apk "网易云音乐 TV版 (大屏黑胶)" "NetEaseMusic.apk" "ext" 17
    install_apk "网络分流扩展客户端 (FlClash TV遥控版)" "Clash.apk" "ext" 24
    install_apk "海外流媒体聚合中心 (Stremio TV版)" "Stremio.apk" "ext" 24
fi

# 5. UI Animations, I/O Debloat, Screensaver & Exact Binary Component Permissions
echo ""
echo "[*] 步骤 4/5: 调优系统渲染动效、I/O减负、4K航拍屏保与桌面底层权限..."
"${ADB[@]}" shell settings put global window_animation_scale 0.5 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global transition_animation_scale 0.5 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global animator_duration_scale 0.5 >/dev/null 2>&1 || true

# Reduce background I/O & wireless scan jitter for smoother 4K HEVC playback
"${ADB[@]}" shell settings put global wifi_scan_always_enabled 0 >/dev/null 2>&1 || true
"${ADB[@]}" shell settings put global ble_scan_always_enabled 0 >/dev/null 2>&1 || true
echo "    [✓] 系统全局动效倍率已调优为 0.5x，已关闭后台无线定位扫描干扰"

# Exact binary package & class names verified from AndroidManifest.xml
PROJ_PKG="com.spocky.projengmenu"
PROJ_MAIN="$PROJ_PKG/com.spocky.projengmenu.ui.home.MainActivity"
PROJ_ACC_SVC="$PROJ_PKG/com.spocky.projengmenu.services.ProjectivyAccessibilityService"

MYTV_PKG="com.github.mytv.android"
MYTV_MAIN="$MYTV_PKG/top.yogiczy.mytv.tv.MainActivity"

AERIAL_PKG="com.neilturner.aerialviews"
AERIAL_DREAM="$AERIAL_PKG/.ui.screensaver.DreamActivity"

CLASH_PKG="com.follow.clash"

# Grant Projectivy, My-TV, AerialViews & FlClash background survival + anti-hibernation privileges
for core_pkg in "$PROJ_PKG" "$MYTV_PKG" "$AERIAL_PKG" "$CLASH_PKG"; do
    "${ADB[@]}" shell appops set "$core_pkg" SYSTEM_ALERT_WINDOW allow >/dev/null 2>&1 || true
    "${ADB[@]}" shell appops set "$core_pkg" RUN_IN_BACKGROUND allow >/dev/null 2>&1 || true
    "${ADB[@]}" shell appops set "$core_pkg" RUN_ANY_IN_BACKGROUND allow >/dev/null 2>&1 || true
    "${ADB[@]}" shell appops set "$core_pkg" AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore >/dev/null 2>&1 || true
    "${ADB[@]}" shell dumpsys deviceidle whitelist +"$core_pkg" >/dev/null 2>&1 || true
done
"${ADB[@]}" shell pm grant "$PROJ_PKG" android.permission.WRITE_SECURE_SETTINGS >/dev/null 2>&1 || true

# Merge Projectivy with existing services, including XiaoAI; verify binding.
if ! bash "$DIR/tv_helper.sh" "$TV_IP" repair-launcher; then
    echo "    [!] 当前无障碍服务未确认绑定，请在电视端检查；不保证重启后保留。"
fi

# Activate Apple TV 4K Aerial Screensaver if installed
if "${ADB[@]}" shell pm path "$AERIAL_PKG" >/dev/null 2>&1; then
    "${ADB[@]}" shell settings put secure screensaver_components "$AERIAL_DREAM" >/dev/null 2>&1 || true
    "${ADB[@]}" shell settings put secure screensaver_enabled 1 >/dev/null 2>&1 || true
    "${ADB[@]}" shell settings put secure screensaver_activate_on_sleep 1 >/dev/null 2>&1 || true
    echo "    [i] 已提交 AerialViews 屏保设置；小米固件的实际空闲触发与播放需另行测试。"
fi

# 6. Hard Safety Gate & Default Launcher Switchover
echo ""
echo "[*] 步骤 5/5: 执行安全硬闸门校验并切换默认系统桌面..."

# HARD GATE 1: Verify Projectivy package is actually installed on /data
PROJ_INSTALLED_PATH="$("${ADB[@]}" shell pm path "$PROJ_PKG" 2>/dev/null | tr -d '\r' || true)"
if [ -z "$PROJ_INSTALLED_PATH" ]; then
    echo "[!] 致命安全拦截 (Hard Gate Triggered)：检测到 Projectivy Launcher 未成功安装！"
    echo "[!] 为保护电视不黑屏，脚本已中止停用小米原生桌面。请检查电视存储空间后重试。"
    exit 1
fi
echo "    [✓] 安全闸门 1 通过: 新桌面安装包已就位 ($PROJ_INSTALLED_PATH)"

# HARD GATE 2: Fail closed if Android reports a launch error.
if ! PROJ_START="$("${ADB[@]}" shell am start -W -n "$PROJ_MAIN" 2>&1)"; then
    echo "[!] Projectivy 启动失败，保留原厂桌面。"
    exit 1
fi
if ! printf '%s\n' "$PROJ_START" | grep -q 'Status: ok'; then
    echo "[!] 未确认 Projectivy 启动成功，保留原厂桌面。"
    exit 1
fi
echo "    [✓] 安全闸门 2 通过: Android 已确认 Projectivy 启动成功"

# Set Projectivy as the legal Android CATEGORY_HOME handler, then freeze stock launcher
if ! HOME_RESULT="$("${ADB[@]}" shell cmd package set-home-activity "$PROJ_MAIN" 2>&1)"; then
    echo "[!] 默认桌面设置失败，保留原厂桌面。"
    exit 1
fi
if ! printf '%s\n' "$HOME_RESULT" | grep -q 'Success'; then
    echo "[!] 未确认默认桌面设置成功，保留原厂桌面。"
    exit 1
fi
"${ADB[@]}" shell pm disable-user --user 0 com.mitv.tvhome >/dev/null
echo "    [✓] 安全闸门 3 完成: 已将 Projectivy 设为系统默认 Home 容器并冻结小米原生桌面"

if [ "$MODE" == "--pure-tv" ]; then
    echo "    [*] 正在激活【长辈纯看电视模式】：立即拉起全屏电视直播 ($MYTV_MAIN)..."
    "${ADB[@]}" shell am start -n "$MYTV_MAIN" >/dev/null 2>&1 || true
fi

# 7. Post-Flight Verification Scorecard
AFTER_FREE_MB="$(get_free_data_mb)"
ALL_INSTALLED="$("${ADB[@]}" shell pm list packages 2>/dev/null | tr -d '\r' || true)"
EXPECTED_PKGS=(
    "com.spocky.projengmenu:Projectivy极简桌面"
    "com.github.mytv.android:My-TV电视直播"
    "com.V2.blb5:BBLL修复版（旧包另行核对）"
    "org.jellyfin.androidtv:Jellyfin家庭影院"
    "com.neilturner.aerialviews:AerialViews航拍屏保"
    "org.smarttube.stable:SmartTube无广告YouTube"
    "com.aurora.store:Aurora开源商店"
    "com.github.tvbox.osc.jun:TVBox聚合播放器"
    "org.localsend.localsend_app:LocalSend局域网闪传"
    "com.netease.cloudmusic.tv:网易云音乐TV黑胶版"
    "com.follow.clash:FlClash分流客户端"
    "com.stremio.one:Stremio全球流媒体"
)

INSTALLED_COUNT=0
echo ""
echo "=========================================================="
echo "          📊 实机部署自动化验收报告 (Post-Flight)         "
echo "=========================================================="
for entry in "${EXPECTED_PKGS[@]}"; do
    pkg_id="${entry%%:*}"
    pkg_label="${entry#*:}"
    if echo "$ALL_INSTALLED" | grep -q "^package:${pkg_id}$"; then
        echo "  [✅ 已就绪] $pkg_label ($pkg_id)"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        echo "  [⚪ 未安装] $pkg_label ($pkg_id)"
    fi
done
echo "----------------------------------------------------------"
echo "  📦 应用就绪统计 : ${INSTALLED_COUNT} / ${#EXPECTED_PKGS[@]} 款已成功落盘"
echo "  💾 闪存空间水准 : 部署前 ${BEFORE_FREE_MB} MB -> 当前剩余 ${AFTER_FREE_MB} MB"
echo "  🛠️ 远控辅助工具 : ./tv_helper.sh $TV_IP (支持秒切模式/推直播源/NAS输入)"
echo "  🔄 原厂无损恢复 : ./restore.sh $TV_IP"
echo "=========================================================="
