# CleanYourTV-Agent 操作提示词 (Prompt)

将以下提示词完整复制并发送给具备终端 Shell 权限的 AI 助手（如 Claude Code, Cursor, Antigravity, OpenDevin, Gemini CLI 等）：

---

```markdown
请帮我将局域网内的红米/小米智能电视深度优化并改造成 Apple TV 极简风格（兼顾长辈开机看电视直播与家庭高清影音）。

我的网络环境与设备信息：
- 电视型号/品牌：红米/小米电视 (Android TV / MIUI TV / HyperOS)
- 电脑与电视处于同一局域网（Wi-Fi 或有线）
- 本地已有完整开源工具包仓库：https://github.com/P-bit-display/cleanyourtv-agent

请按以下严格工程准则执行：
1. 建立连接：
   - 扫描局域网 ARP 表或端口 5555 找到电视 IP，并通过 ADB 连接。
   - 如果电视提示未授权，提醒我在电视屏幕上按遥控器允许调试。
2. 安全备份：
   - 必须先将电视当前的包清单 (pm list packages) 和 getprop 信息备份到本地 backup/ 目录。
3. 彻底粉碎广告与垃圾服务：
   - 清除 /sdcard/Android/data/com.xiaomi.mitv.advertise/files/* 等离线广告预存视频池。
   - 使用 pm disable-user --user 0 停用小米 9 大广告、推荐与大数据采集组件。
   - 严禁禁用小爱同学语音服务 (com.xiaomi.voiceassistant)、蓝牙驱动与信号源设置。
4. 安装核心生态应用：
   - 安装 Projectivy Launcher (Apple tvOS 风格桌面)、My-TV (开机电视直播)、FlClash (TV专属科学上网)、SmartTube (免广告YouTube)、Jellyfin (直连群晖)、BBLL (B站4K)、TVBox、网易云音乐、AerialViews (苹果4K屏保) 和 LocalSend。
5. 桌面防软砖自检与切换：
   - 在停用原厂桌面 com.mitv.tvhome 之前，必须先通过 am start 强制拉起新桌面并检查运行栈，确认健康存活后才切换默认桌面。
   - 将 Projectivy 加入电池与内存防杀白名单 (dumpsys deviceidle whitelist)。
6. 引导我完成最终测试（开机直达直播、按 Home 键切 Apple 桌面、小爱语音测试），并提醒我在完工后关闭电视的 ADB 调试开关以物理关门。
```
