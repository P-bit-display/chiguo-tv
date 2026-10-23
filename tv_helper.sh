#!/usr/bin/env bash
# ==============================================================================
# 赤果 (ChiGuo · RedApple TV) -> 电视远控、双机扫描与免ADB控制瑞士军刀 (v5.0)
# Supports both Port 6095 (Zero-ADB HTTP Remote) and Port 5555 (ADB Deep Control)
# ==============================================================================

set -e

ADB_BIN="/opt/homebrew/bin/adb"
if [ ! -f "$ADB_BIN" ]; then
    ADB_BIN="$(which adb || true)"
fi

TV_IP="${1:-192.0.2.10}"
CMD="${2:-status}"
ARG="${3:-}"

if [ "$TV_IP" == "scan" ] || [ "$CMD" == "scan" ]; then
    echo "[*] 正在扫描局域网 (192.0.2.0/24) 内的全部小米/红米电视..."
    python3 -c '
import socket, concurrent.futures, urllib.request, re
def probe(i):
    ip = f"192.0.2.{i}"
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(0.25)
    if s.connect_ex((ip, 6095)) == 0:
        s.close()
        adb_s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        adb_s.settimeout(0.2)
        adb_open = (adb_s.connect_ex((ip, 5555)) == 0)
        adb_s.close()
        name = "小米/红米电视"
        try:
            r = urllib.request.urlopen(f"http://{ip}:6095/controller?action=getsysteminfo", timeout=0.6).read().decode("utf-8", errors="ignore")
            m = re.search(r"\"devicename\":\"([^\"]+)\"", r)
            if m: name = m.group(1)
        except Exception:
            pass
        return (ip, name, adb_open)
    s.close()
    return None
with concurrent.futures.ThreadPoolExecutor(max_workers=64) as ex:
    found = [r for r in ex.map(probe, range(2, 254)) if r]
if not found:
    print("  [!] 未发现处于开机联网状态的小米/红米电视。")
else:
    for ip, name, adb_open in found:
        adb_str = "✅ ADB调试已开启(5555端口就绪)" if adb_open else "⚠️ ADB调试未开启(可运行 ./tv_helper.sh " + ip + " open-settings 自动弹出设置)"
        print(f"  📺 发现电视: {ip:15s} | 名称: {name} | 状态: {adb_str}")
'
    exit 0
fi

# Zero-ADB commands via Port 6095 (work even before ADB 5555 is enabled!)
case "$CMD" in
    open-settings)
        echo "[*] 正在通过小米 6095 远控协议在电视 ($TV_IP) 上直接弹出【系统设置】界面 (无需 ADB)..."
        curl -s -m 3 "http://$TV_IP:6095/controller?action=startapp&type=packagename&packagename=com.xiaomi.mitv.settings" >/dev/null
        echo "[✓] 电视屏幕已弹出【设置】！请用遥控器操作："
        echo "    1. 进【关于】-> 在【产品型号】上连按 7 次确定键开启开发者模式；"
        echo "    2. 进【账号与安全】-> 将【ADB 调试】设为【允许】。"
        exit 0
        ;;
    apps)
        echo "[*] 正在通过 6095 协议读取电视 ($TV_IP) 当前已安装应用列表 (无需 ADB)..."
        python3 -c "
import urllib.request, json
r = urllib.request.urlopen('http://$TV_IP:6095/controller?action=getinstalledapp&count=999&changeIcon=1', timeout=3).read().decode('utf-8', errors='ignore')
for a in json.loads(r)['data']['AppInfo']:
    print(f\"  {a['Order']:2d}. {a['AppName']:16s} -> {a['PackageName']}\")
"
        exit 0
        ;;
    key)
        if [ -z "$ARG" ]; then
            echo "用法: ./tv_helper.sh $TV_IP key <up|down|left|right|enter|back|home|menu|volumeup|volumedown>"
            exit 1
        fi
        curl -s -m 2 "http://$TV_IP:6095/controller?action=keyevent&keycode=$ARG" >/dev/null
        echo "[✓] 已发送按键: $ARG"
        exit 0
        ;;
esac

TARGET="$TV_IP:5555"
ADB=("$ADB_BIN" -s "$TARGET")
$ADB_BIN connect "$TARGET" >/dev/null 2>&1 || true

PROJ_MAIN="com.spocky.projengmenu/com.spocky.projengmenu.ui.home.MainActivity"
MYTV_MAIN="com.github.mytv.android/top.yogiczy.mytv.tv.MainActivity"

case "$CMD" in
    status)
        echo "=========================================================="
        echo "    🍎 赤果 (ChiGuo) · 电视实时运行体检 ($TARGET)"
        echo "=========================================================="
        MODEL="$("${ADB[@]}" shell getprop ro.product.model | tr -d '\r')"
        ANDROID_VER="$("${ADB[@]}" shell getprop ro.build.version.release | tr -d '\r')"
        echo "📺 设备型号 : $MODEL (Android $ANDROID_VER)"
        echo "💾 /data存储: $("${ADB[@]}" shell df -h /data | tail -n 1 | awk '{print "总计 "$2", 已用 "$3", 剩余可用 "$4" ("$5")"}')"
        echo "🧠 内存状态 : $("${ADB[@]}" shell free -m | grep Mem | awk '{print "总计 "$2"MB, 已用 "$3"MB, 空闲/缓存 "$4+$6"MB"}')"
        echo "🎯 当前窗口 : $("${ADB[@]}" shell dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp' | head -n 2 | tr -d '\r')"
        ;;
    clean-bloat)
        echo "[*] 正在冻结/清理电视上多余的预装游戏与推广组件以释放 /data 空间..."
        EXTRA_BLOAT=(
            "com.lutongnet.nldmxXiaomiChildren"
            "com.tencent.start.tv"
            "com.tvbc.mddtv"
            "com.xiaomi.tv.gallery"
            "com.duokan.videodaily"
            "com.xiaomi.mitv.handbook"
        )
        for bpkg in "${EXTRA_BLOAT[@]}"; do
            "${ADB[@]}" shell pm clear "$bpkg" >/dev/null 2>&1 || true
            "${ADB[@]}" shell pm disable-user --user 0 "$bpkg" >/dev/null 2>&1 || true
            echo "    [✓] 已清理并冻结: $bpkg"
        done
        "${ADB[@]}" shell pm trim-caches 999999999999999999 >/dev/null 2>&1 || true
        echo "[✓] 深度空间清理完成！"
        ;;
    text)
        if [ -z "$ARG" ]; then
            echo "用法: ./tv_helper.sh $TV_IP text \"http://192.0.2.20:8096\""
            exit 1
        fi
        echo "[*] 正在向电视当前输入框隔空投送文字: $ARG"
        ESCAPED="${ARG// /%s}"
        "${ADB[@]}" shell input text "$ESCAPED"
        echo "[✓] 投送完成！"
        ;;
    nas)
        NAS_URL="${ARG:-http://192.0.2.20:8096}"
        echo "[*] 正在向电视一键输入群晖 Jellyfin 地址: $NAS_URL"
        "${ADB[@]}" shell input text "$NAS_URL"
        echo "[✓] 群晖地址输入完成！"
        ;;
    push-mytv)
        if [ -z "$ARG" ]; then
            echo "用法: ./tv_helper.sh $TV_IP push-mytv <本地tv.txt路径_或_M3U直播源内容文件>"
            exit 1
        fi
        if [ -f "$ARG" ]; then
            echo "[*] 正在将本地直播源文件直推至电视 My-TV 默认读取路径 (/sdcard/Download/tv.txt)..."
            "${ADB[@]}" push "$ARG" /sdcard/Download/tv.txt
            echo "[✓] 直播源文件已就位！重启 My-TV 即可直接加载。"
        else
            echo "[!] 未找到本地文件: $ARG"
            exit 1
        fi
        ;;
    push-tvbox)
        if [ -z "$ARG" ]; then
            echo "用法: ./tv_helper.sh $TV_IP push-tvbox \"https://.../api.json\""
            exit 1
        fi
        echo "[*] 正在通过 TVBox 内置 9978 端口 API 免遥控器直推接口地址..."
        if curl -s -m 5 --data-urlencode "do=push" --data-urlencode "url=$ARG" "http://$TV_IP:9978/action" >/dev/null; then
            echo "[✓] TVBox 接口地址推送成功！(请确保电视当前已打开 TVBox 设置页)"
        else
            echo "[!] 9978 端口未响应 (请先在电视上打开 TVBox)，已自动回退为 ADB 键盘输入..."
            "${ADB[@]}" shell input text "$ARG"
        fi
        ;;
    settings)
        echo "[*] 正在直接唤起电视底层系统设置 (Wi-Fi / 蓝牙 / 图像与声音)..."
        "${ADB[@]}" shell am start -a android.settings.SETTINGS >/dev/null 2>&1 || true
        echo "[✓] 系统设置已打开！"
        ;;
    mode-pure)
        echo "[*] 正在秒切至【纯看电视·长辈模式】(无需重装应用)..."
        "${ADB[@]}" shell am start -n "$MYTV_MAIN"
        echo "[✓] 已切入全屏电视直播！"
        ;;
    mode-apple)
        echo "[*] 正在秒切至【Apple TV 极简桌面模式】..."
        "${ADB[@]}" shell am start -n "$PROJ_MAIN"
        echo "[✓] 已切入 Projectivy 极简桌面！"
        ;;
    hdmi1)
        echo "[*] 正在切换电视信号源至 HDMI 1 (外接 Apple TV / 主机)..."
        "${ADB[@]}" shell am start -n "com.spocky.projengmenu/com.spocky.projengmenu.ui.guidedActions.activities.input.SourceHDMI1Activity"
        ;;
    hdmi2)
        echo "[*] 正在切换电视信号源至 HDMI 2..."
        "${ADB[@]}" shell am start -n "com.spocky.projengmenu/com.spocky.projengmenu.ui.guidedActions.activities.input.SourceHDMI2Activity"
        ;;
    screensaver)
        echo "[*] 正在立即预览 Apple TV 4K 航拍屏保..."
        "${ADB[@]}" shell am start -n "com.neilturner.aerialviews/.ui.screensaver.TestActivity"
        ;;
    screenshot)
        OUT_FILE="tv_screen_$(date +%Y%m%d_%H%M%S).png"
        echo "[*] 正在截取电视高清画面..."
        "${ADB[@]}" exec-out screencap -p > "$OUT_FILE"
        echo "[✓] 截图已保存至当前目录: $OUT_FILE"
        ;;
    *)
        echo "用法: ./tv_helper.sh <电视IP|scan> <指令> [参数]"
        echo ""
        echo "🔍 免 ADB 远控指令 (通过 6095 端口，未开 ADB 调试也能直接用):"
        echo "  scan               - 扫描局域网内全部小米/红米电视的 IP 与状态"
        echo "  open-settings      - 直接在电视屏幕上自动弹出【系统设置】界面"
        echo "  apps               - 查看电视当前已安装的全部应用与包名清单"
        echo "  key <按键>         - 电脑充当无线遥控器 (up/down/left/right/enter/back/home)"
        echo ""
        echo "⚡ ADB 深度控制指令 (开启 ADB 调试后可用):"
        echo "  status             - 查看电视内存、闪存剩余空间与当前前台窗口"
        echo "  clean-bloat        - 清理预装儿童训练/云游戏/粤视厅等冗余包释放空间"
        echo "  nas [地址]         - 一键输入您的群晖 NAS 地址 (默认 http://192.0.2.20:8096)"
        echo "  text <内容>        - 隔空向电视输入框打字 (免遥控器敲网址/订阅链接)"
        echo "  push-mytv <文件>   - 免遥控器将本地直播源文件直推至 My-TV (/sdcard/Download/tv.txt)"
        echo "  push-tvbox <URL>   - 通过 TVBox 9978 端口 API 免遥控器直推影视接口地址"
        echo "  mode-pure          - 1秒热切换至【长辈全屏看电视模式】"
        echo "  mode-apple         - 1秒热切换至【Apple TV 极简桌面】"
        echo "  hdmi1 / hdmi2      - 一键直达 HDMI 1 / HDMI 2 信号源 (切实体 Apple TV/主机)"
        echo "  screensaver        - 立即启动 Apple TV 4K 航拍屏保预览"
        echo "  screenshot         - 一键截取电视当前屏幕保存到电脑"
        ;;
esac
