#!/usr/bin/env bash
# ================================================================
# 赤果 (ChiGuo) · 小米/红米电视极简系统一键安装工具 (macOS 双击版)
# ================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

# 检查 ADB
ADB_BIN="$(which adb || true)"
if [ -z "$ADB_BIN" ] && [ -f "/opt/homebrew/bin/adb" ]; then
    ADB_BIN="/opt/homebrew/bin/adb"
fi

if [ -z "$ADB_BIN" ]; then
    echo "=========================================================="
    echo "[!] 未检测到系统 ADB。正在为您自动下载官方便携版 ADB..."
    echo "=========================================================="
    mkdir -p "$DIR/bin"
    curl -fsSL https://dl.google.com/android/repository/platform-tools-latest-darwin.zip -o "$DIR/bin/adb.zip"
    unzip -q -o "$DIR/bin/adb.zip" -d "$DIR/bin"
    chmod +x "$DIR/bin/platform-tools/adb"
    ADB_BIN="$DIR/bin/platform-tools/adb"
    rm -f "$DIR/bin/adb.zip"
fi

clear
echo "================================================================"
echo "   🍎 赤果 (ChiGuo · RedApple TV) 小米/红米电视一键极简改装工具 "
echo "================================================================"
echo ""
echo " 本工具专为普通用户设计："
echo " - 彻底清理开机广告、商城、弹窗与后台耗电全家桶"
echo " - 一键改装为 Apple tvOS 极简毛玻璃美学桌面与 4K 原生航拍屏保"
echo " - 优化电视直播、解决 5 秒循环、配置 0.5x 动画与防关机"
echo ""
echo "================================================================"
echo ""

# 探测 IP
read -p "请输入电视的局域网 IP 地址 (例如 192.168.50.41，直接按回车将自动扫描): " TV_IP

if [ -z "$TV_IP" ]; then
    echo "[*] 正在自动扫描局域网内的小米/红米电视..."
    LOCAL_IP="$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || true)"
    if [ -n "$LOCAL_IP" ]; then
        PREFIX="${LOCAL_IP%.*}"
        TV_IP="$(python3 -c "
import socket, concurrent.futures
prefix = '$PREFIX'
def check(i):
    ip = f'{prefix}.{i}'
    for port in (5555, 6095):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.18)
        if s.connect_ex((ip, port)) == 0:
            s.close()
            return ip
        s.close()
    return None
with concurrent.futures.ThreadPoolExecutor(max_workers=64) as ex:
    res = [r for r in ex.map(check, range(2, 254)) if r]
print(res[0] if res else '')
")"
    fi
fi

if [ -z "$TV_IP" ]; then
    echo "[!] 未能自动发现电视，请在电视「设置 -> 关于 -> 网络信息」中查看电视 IP 后重新输入。"
    read -p "请输入电视 IP: " TV_IP
fi

TARGET="$TV_IP:5555"
echo ""
echo "[*] 正在连接目标电视: $TARGET ..."
"$ADB_BIN" kill-server >/dev/null 2>&1 || true
"$ADB_BIN" connect "$TARGET"

echo "[*] 正在等待电视授权与连接..."
"$ADB_BIN" -s "$TARGET" wait-for-device

echo ""
echo "================================================================"
echo "  连接成功！请选择您要执行的改装模式："
echo "  [1] 🌟 全套改装：Apple TV 极简桌面 + 去广告 + 直播优化 + 性能加速 (推荐)"
echo "  [2] 📺 长辈看电视模式：开机直达电视直播 + 去除所有广告"
echo "  [3] 🧹 仅深度净化：停用系统广告、推送、游戏中心与商城"
echo "  [4] ⚡ 仅性能调优：0.5x 动画缩放 + 防待机自动关机 + AOT 速度编译"
echo "  [5] 📡 推送苏州移动 112 高清频道源 (央视/卫视/地方台)"
echo "  [6] ↩️ 恢复出厂状态：重新启用原厂小米桌面与官方服务"
echo "  [0] 退出"
echo "================================================================"
read -p "请输入选项序号 [1-6]: " CHOICE

case "$CHOICE" in
    1)
        echo "[*] 开始执行全套改装..."
        # 1. Debloat
        echo "[*] 正在净化广告全家桶..."
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

        # 2. Install
        echo "[*] 正在安装核心影音应用..."
        [ -f "$DIR/apks/AerialViews.apk" ] && "$ADB_BIN" -s "$TARGET" install -r -d "$DIR/apks/AerialViews.apk"
        [ -f "$DIR/apks/MyTV.apk" ] && "$ADB_BIN" -s "$TARGET" install -r -d "$DIR/apks/MyTV.apk"
        [ -f "$DIR/apks/Clash.apk" ] && "$ADB_BIN" -s "$TARGET" install -r -d "$DIR/apks/Clash.apk"
        [ -f "$DIR/apks/SmartTube.apk" ] && "$ADB_BIN" -s "$TARGET" install -r -d "$DIR/apks/SmartTube.apk"
        [ -f "$DIR/apks/BBLL.apk" ] && "$ADB_BIN" -s "$TARGET" install -r -d "$DIR/apks/BBLL.apk"
        [ -f "$DIR/apks/Jellyfin.apk" ] && "$ADB_BIN" -s "$TARGET" install -r -d "$DIR/apks/Jellyfin.apk"
        [ -f "$DIR/ImmichTV-6.2.0.apk" ] && "$ADB_BIN" -s "$TARGET" install -r -d "$DIR/ImmichTV-6.2.0.apk"

        # 3. Settings
        echo "[*] 正在优化系统动画与电源策略..."
        "$ADB_BIN" -s "$TARGET" shell settings put global window_animation_scale 0.5
        "$ADB_BIN" -s "$TARGET" shell settings put global transition_animation_scale 0.5
        "$ADB_BIN" -s "$TARGET" shell settings put global animator_duration_scale 0.5
        "$ADB_BIN" -s "$TARGET" shell settings put global stay_on_while_plugged_in 3
        "$ADB_BIN" -s "$TARGET" shell settings put system screen_off_timeout 2147483647
        "$ADB_BIN" -s "$TARGET" shell settings put global hdmi_control_auto_shutdown 0
        "$ADB_BIN" -s "$TARGET" shell settings put global auto_update_system 0

        # 4. Push IPTV
        if [ -f "$DIR/suzhou_mobile.m3u" ]; then
            echo "[*] 正在推送央视与卫视高清频道..."
            "$ADB_BIN" -s "$TARGET" push "$DIR/suzhou_mobile.m3u" /sdcard/Download/suzhou_mobile.m3u
        fi

        # 5. Launcher setup & AOT
        echo "[*] 正在激活 Apple TV 桌面与 AOT 提速..."
        "$ADB_BIN" -s "$TARGET" shell pm grant app.orchard.tv android.permission.WRITE_SECURE_SETTINGS >/dev/null 2>&1 || true
        "$ADB_BIN" -s "$TARGET" shell pm grant app.orchard.tv android.permission.SYSTEM_ALERT_WINDOW >/dev/null 2>&1 || true
        "$ADB_BIN" -s "$TARGET" shell dumpsys deviceidle whitelist +app.orchard.tv >/dev/null 2>&1 || true
        "$ADB_BIN" -s "$TARGET" shell cmd package set-home-activity app.orchard.tv/.MainActivity >/dev/null 2>&1 || true
        "$ADB_BIN" -s "$TARGET" shell am start -n app.orchard.tv/.MainActivity >/dev/null 2>&1 || true
        "$ADB_BIN" -s "$TARGET" shell cmd package compile -m speed -f app.orchard.tv >/dev/null 2>&1 || true
        
        echo ""
        echo "================================================================"
        echo " 🎉 全套改装完成！请拿起遥控器按 Home 键体验极简桌面！"
        echo "================================================================"
        ;;
    6)
        echo "[*] 正在恢复原厂设置..."
        "$ADB_BIN" -s "$TARGET" shell pm enable com.mitv.tvhome >/dev/null 2>&1 || true
        "$ADB_BIN" -s "$TARGET" shell cmd package set-home-activity com.mitv.tvhome/com.mitv.tvhome.MainActivity >/dev/null 2>&1 || true
        "$ADB_BIN" -s "$TARGET" shell pm enable com.xiaomi.mitv.appstore >/dev/null 2>&1 || true
        "$ADB_BIN" -s "$TARGET" shell pm enable com.xiaomi.mitv.upgrade >/dev/null 2>&1 || true
        "$ADB_BIN" -s "$TARGET" shell settings put global window_animation_scale 1.0
        "$ADB_BIN" -s "$TARGET" shell settings put global transition_animation_scale 1.0
        "$ADB_BIN" -s "$TARGET" shell settings put global animator_duration_scale 1.0
        echo "[√] 原厂桌面与官方设置已恢复！"
        ;;
    *)
        echo "已取消。"
        ;;
esac

echo ""
read -n 1 -s -r -p "按任意键退出..."
echo ""
