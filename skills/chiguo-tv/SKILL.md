---
name: chiguo-tv
description: 局域网红米/小米电视深度优化、Apple tvOS 极简美学改造、广告净化与影音生态配置专家技能。
---

# 赤果 (ChiGuo · RedApple TV) 电视优化与极简改造技能

此 Skill 专为局域网内的 **红米 / 小米智能电视 (Android 9 / MIUI TV / HyperOS)** 打造，用于将其深度优化并重构为 **Apple tvOS 极简美学风格**，兼顾“长辈开机看高清直播”与“家庭高品质影音流媒体中心”。

---

## 核心设计与工程准则

1. **安全第一与防变砖机制**：
   - 在停用原厂桌面 (`com.mitv.tvhome`) 之前，**必须先通过 `am start` 拉起目标第三方桌面并检查运行栈**，确认正常显示后才可执行 `cmd package set-home-activity`。
   - 严禁禁用小爱同学语音核心 (`com.xiaomi.voicecontrol`)、蓝牙驱动、红外遥控接收、WiFi 核心及信号源管理。
   - 调试与操作前，必须将当前包列表与系统属性备份到本地 `backup/` 目录。

2. **桌面选型与系统接管**：
   - 默认桌面采用 **Aerial TV** (`app.orchard.tv`)，具备原生 Apple TV 毛玻璃质感、悬浮对焦动画及 114 个 4K 航拍屏保。
   - 授予 `WRITE_SECURE_SETTINGS` 与 `SYSTEM_ALERT_WINDOW` 权限，并加入电池优化防杀白名单 (`dumpsys deviceidle whitelist +app.orchard.tv`)。
   - 执行 AOT 速度编译：`cmd package compile -m speed -f app.orchard.tv` 消除低配芯片渲染卡顿。

3. **直播播放器（MyTV）调优**：
   - 解决 5 秒循环播放问题：在配置中将 `videoPlayerSkipMultipleFramesOnSameVSync` 设置为 `false`。
   - 频道源维护：通过本地推送或局域网 HTTP 服务向 `/sdcard/Download/` 提供 112+ 央视/卫视/地方高清直播源。

4. **代理网络分流原则（FlClash）**：
   - **严格使用白名单模式（应用访问控制）**：仅勾选 SmartTube 走 TUN 虚拟网卡，其他应用（Jellyfin、MyTV、BBLL、LocalSend、爆米花）全部排除在代理之外。
   - 避免全局 TUN 模式导致原生 IPv6 被黑洞丢弃或 NAS 局域网访问降速。

5. **私有云相册（Immich TV）直连准则**：
   - 电视端拉取大量缩略图会触发公网 CDN/Cloudflare 防刷 403 拦截，必须强制配置局域网直连 IP (`http://192.168.x.x:2283`)。

6. **电视硬件功耗与屏幕保护**：
   - 防止看片中途自动休眠关机：设置 `stay_on_while_plugged_in=3`、`screen_off_timeout=2147483647`、`hdmi_control_auto_shutdown=0`。
   - 全局动画提速：将 `window_animation_scale`、`transition_animation_scale`、`animator_duration_scale` 统一设置为 `0.5`。
   - 全局更新静音：设置 `auto_update_system=0`，并将应用通知权限设为 `ignore`。

7. **物理安全关门**：
   - 部署全部完成后，向用户确认是否需要关闭电视 ADB 调试端口，防止局域网长期暴露 5555 端口。

---

## 常用 ADB 快速指令清单

### 1. 扫描与连接
```bash
# 扫描局域网电视 IP 并连接
adb connect <TV_IP>:5555

# 电视未开调试时，利用 6095 端口远程在电视屏幕弹开设置引导
curl -s -m 1 "http://<TV_IP>:6095/controller?action=keyevent&keycode=settings"
```

### 2. 深度精简（Debloat 核心名单）
```bash
# 停用广告、埋点与应用商店
adb shell pm disable-user --user 0 com.miui.analytics
adb shell pm disable-user --user 0 com.miui.tv.analytics
adb shell pm disable-user --user 0 com.xiaomi.statistic
adb shell pm disable-user --user 0 com.xm.webcontent
adb shell pm disable-user --user 0 com.xiaomi.mitv.tvpush.tvpushservice
adb shell pm disable-user --user 0 com.mitv.screensaver
adb shell pm disable-user --user 0 com.xiaomi.mibox.lockscreen
adb shell pm disable-user --user 0 com.cmgame.gamehall.xmtv
adb shell pm disable-user --user 0 com.xiaomi.mitv.shoplugin
adb shell pm disable-user --user 0 com.xiaomi.mitv.appstore
adb shell pm disable-user --user 0 com.xiaomi.mitv.upgrade
```

### 3. 系统参数优化
```bash
# 动画缩放提速至 0.5x
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb shell settings put global animator_duration_scale 0.5

# 防误休眠与防关机
adb shell settings put global stay_on_while_plugged_in 3
adb shell settings put system screen_off_timeout 2147483647
adb shell settings put global hdmi_control_auto_shutdown 0
adb shell settings put global auto_update_system 0
```

### 4. 核心应用 AOT 机器码预编译（消除掉帧）
```bash
adb shell cmd package compile -m speed -f app.orchard.tv
adb shell cmd package compile -m speed -f com.github.mytv.android
adb shell cmd package compile -m speed -f org.jellyfin.androidtv
adb shell cmd package compile -m speed -f com.V2.blb5
adb shell cmd package compile -m speed -f nl.giejay.android.tv.immich
```
