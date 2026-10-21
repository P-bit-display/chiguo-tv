# 🍎 赤果 (ChiGuo) · RedApple TV

<p align="center">
  <img src="https://img.shields.io/badge/Project-赤果%20ChiGuo-red?style=for-the-badge" alt="Project">
  <img src="https://img.shields.io/badge/Style-Apple%20tvOS%20Aesthetics-black?style=for-the-badge&logo=apple" alt="Apple tvOS">
  <img src="https://img.shields.io/badge/Platform-Android%20TV%20%7C%20MIUI%20TV%20%7C%20HyperOS-blue?style=for-the-badge&logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/Driven%20by-AI%20Agent-purple?style=for-the-badge&logo=openai" alt="AI Agent">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

<p align="center">
  <img src="docs/banner.jpg" alt="赤果 ChiGuo · RedApple TV" width="100%">
</p>

<p align="center">
  <a href="README.en.md">English</a> · 
  <b>简体中文</b> · 
  <a href="README.zh-TW.md">繁體中文</a> · 
  <a href="README.ja.md">日本語</a> · 
  <a href="README.ru.md">Русский</a> · 
  <a href="README.es.md">Español</a>
</p>

<p align="center">
  <b>让红米/小米电视拥有 Apple tvOS 般极简优雅体验</b><br>
  <i>红米 (Red) + 苹果 (Apple) = 赤果 · 删繁就简，返璞归真</i>
</p>

---

## 📖 项目简介

**赤果 (ChiGuo)** 是一个面向 Android TV / 小米电视 / 红米电视的开源自动化调优套件。无需 Root、不刷底层固件、零变砖风险，利用 **AI Agent + 局域网 ADB 协议**，对电视系统进行深度资源释放与后台轻量化，换装极简优雅的 **tvOS 风格桌面**，并打通 **开机直达电视直播、B站 4K、群晖 NAS 影院与多媒体中心**。

> 💡 **设计初心**：现在的智能电视满屏推荐信息流、后台推送繁重，长辈想看个中央台往往要按十几下遥控器。赤果通过自动化控制，让电视回归“通电即看、纯净极简”的本质。

---

## 🔍 核心特性

- ⚡ **开机直达电视节目**：通电自动进入全屏电视直播，遥控器上下键切换频道，保留长辈最习惯的操作模式。
- 🍏 **tvOS 极简美学桌面**：采用经过社区长年检验的 Projectivy Launcher，大圆角动态卡片、高斯模糊毛玻璃背景，按 Home 键随时呼出极简主页。
- 🍃 **后台轻量化与资源释放**：停用冗余的后台推送、商城服务与数据采集组件，彻底清理系统离线缓存，运存（RAM）释放达 40%~60%，老电视重获丝滑。
- 🍿 **全能家庭影音生态**：
  - **哔哩哔哩 TV版 (BBLL)**：支持 4K 120Hz、杜比视界，弹幕流畅无干扰。
  - **私有家庭影院 (Jellyfin)**：直连群晖 NAS 局域网影音库，呈现电影海报墙，芯片硬件直解。
  - **海外流媒体聚合 (Stremio TV)**：全球极客推崇的开源流媒体中枢，海量剧集电影 4K 秒播与多国字幕。
  - **开源应用商店 (Aurora Store TV)**：免装 GMS 谷歌框架，大屏直接下载正版海外应用。
  - **网络分流扩展 (FlClash TV版)**：电视遥控器方向键完美适配，支持基于规则的网络分流。
  - **海外高清视频 (SmartTube)**：4K/8K 杜比视界，免 GMS 谷歌框架运行，彻底去除插播广告。
  - **开源聚合播放器 (TVBox)**：轻量纯净播放内核，支持导入自定义开源数据源。
  - **大屏黑胶音乐 (网易云音乐 TV版)**：大屏黑胶唱片视觉设计与客厅氛围音乐。
  - **Apple TV 4K 动态航拍屏保 (AerialViews)**：空闲待机时轮播苹果官方 4K 航拍超清动态壁纸。
  - **局域网文件互传 (LocalSend)**：跨平台局域网文件闪传，电脑/手机无线向电视发送文件。
- 🛡️ **工业级防软砖与系统加固**：具备桌面预检自拉起、低内存防杀白名单（Anti-LMK），100% 保留遥控器小爱同学语音键与 HDMI-CEC 信号源控制。
- 🔄 **100% 无损随时还原**：配套提供 `restore.sh` 脚本，一条命令瞬间复原小米官方原厂出厂状态。

---

## ❓ 常见问题答疑 (FAQ)

**Q1：优化后，遥控器上的“小爱同学”语音键还能用吗？**  
A：**完全正常可用！** 我们的白名单策略严禁触碰 `com.xiaomi.voiceassistant`。在任意第三方桌面或应用内按下语音键，依旧会在屏幕下方呼出原生半透明语音条，支持查天气、调音量、搜片。

**Q2：米家（智能家居联动/门铃监控）会受影响吗？**  
A：**不受任何影响！** 脚本默认完整保留米家电视组件与画质驱动，智能门铃弹窗、摄像头画中画及家庭联动 100% 正常。

**Q3：TVBox 安装后打开是空的，怎么配置？**  
A：TVBox 是开源纯净播放器。打开 TVBox 后，进入【设置】->【配置地址】，输入任意公开的多仓订阅接口（例如在手机上通过 LocalSend 发送配置链接），确认后即可瞬间加载全网资源。

**Q4：如果以后想恢复出厂系统怎么办？**  
A：随时在电脑终端运行 `./restore.sh <电视IP>`，脚本会在 3 秒内解冻所有小米原生组件并切换回原厂桌面，完全不影响官方售后保修。

---

## 🤖 快速使用：交给你的 AI 编程助手

如果你在电脑上使用 [Claude Code](https://claude.com/product/claude-code)、Cursor 或其他具备终端权限的 AI Agent：

1. 电视开启【开发者选项 -> 允许 ADB 调试】。
2. 将本项目中的 [`PROMPT.md`](PROMPT.md) 内容直接复制给 AI Agent。
3. AI 将自动探测局域网电视并完成全部安全调优与桌面配置。

---

## 🛠️ 手动一键运行（支持两种模式）

1. 确保电脑与电视处于同一个局域网。
2. 电视开启【ADB 调试】（设置 -> 关于 -> 连按版本号 5 次开启开发者选项 -> 允许 ADB 调试）。
3. 终端运行部署脚本（按家庭场景二选一）：

### 选项 A：全能双模（年轻人 + 长辈通吃，默认推荐）
```bash
./deploy.sh <你的电视IP>
```
* **体验**：开机无广告直达电视直播（CCTV/卫视），按遥控器【Home 键】秒切 Apple TV 极简桌面，随时畅享 B站 4K、群晖 NAS 影院与海外流媒体。

### 选项 B：纯看电视·长辈锁死模式（专治老人误触）
```bash
./deploy.sh <你的电视IP> --pure-tv
```
* **体验**：**彻底锁死电视直播！** 电视通电就是画面，按 Home 键或返回键只会调出节目单，**绝对不会跳出到任何智能系统或设置菜单**，真正还原老式有线电视的零门槛体验。

---

### 🛡️ 一键出厂还原（后悔药）
无论此前安装了哪种模式，任何时候需要保修或恢复小米官方出厂系统：
```bash
./restore.sh <你的电视IP>
```
3 秒内完整解冻全部官方组件并切回官方桌面，无任何后遗症。

---

## 🗂️ 项目文件结构

```
├── apks/                         # 10 大核心生态应用官方安装包
│   ├── ProjectivyLauncher.apk    # tvOS 风格极简桌面
│   ├── MyTV.apk                  # 开机即播电视直播客户端
│   ├── Clash.apk                 # 电视遥控器专属网络分流工具 (FlClash)
│   ├── SmartTube.apk             # 4K 高清播放器 (SmartTube)
│   ├── BBLL.apk                  # 哔哩哔哩 TV版 (4K/杜比视界)
│   ├── Jellyfin.apk              # 个人家庭影院 (直连群晖 NAS)
│   ├── TVBox.apk                 # 开源聚合播放器
│   ├── NetEaseMusic.apk          # 网易云音乐 TV 官方大屏版
│   ├── AerialViews.apk           # 4K 动态航拍屏保
│   └── LocalSend.apk             # 局域网跨设备文件互传
├── deploy.sh                     # 🚀【自动化部署脚本】
├── restore.sh                    # 🛡️【一键还原脚本】(随时秒回官方状态)
├── PROMPT.md                     # 🤖【AI Agent 标准化操作提示词】
├── redmi_tv_apple_system_ultimate_spec.md # 终极系统技术架构规范
├── redmi_tv_red_blue_review.md   # 🔴🔵 红蓝军 10 轮攻防审查报告
├── redmi_tv_test_cases_and_risks.md       # 14 项全流程测试用例
└── LICENSE                       # MIT 开源协议
```

---

## 🏷️ 检索标签 (Keywords)

`红米电视系统优化` · `小米电视极简桌面` · `CleanYourTV 中文版` · `赤果 TV` · `Claude Code 电视调优` · `Apple TV 桌面风格` · `tvOS for Android TV` · `红米电视开机看电视` · `电视看B站4K杜比` · `电视安装Jellyfin直连群晖` · `Projectivy Launcher 小米电视` · `小米电视澎湃OS HyperOS 优化` · `电视ADB系统精简`

---

## ⚖️ 免责声明 (Disclaimer)

1. **开源研究性质**：本项目为开源技术爱好者对 Android TV 系统底层机制的调优研究与学习成果，仅供个人技术交流与合法设备维护使用。
2. **硬件所有权与权益**：用户对个人购买的电视硬件享有合法的排他性支配权与软件设置自主权。本项目不破解系统 Bootloader、不涉及硬改固件，所有操作均基于 Android 官方原生公开的 ADB 调试协议。
3. **内容版权声明**：本项目不提供、不制作、不传播、不存储任何音视频节目或受版权保护的商业资源；项目中提及或集成的第三方客户端软件均为开源社区或厂商官方公开分发版本，其版权归各自原始权利人所有。
4. **商标声明**：文中所提及的“小米（Xiaomi）”、“红米（Redmi）”、“苹果（Apple）”、“Apple TV”、“tvOS”、“哔哩哔哩（Bilibili）”等商标与产品名称，仅作为兼容性技术描述与风格说明使用，本项目与上述商标持有方不存在任何商业合作、赞助或隶属关系。
5. **用户自担责任**：请使用者在遵守所在地区法律法规及设备用户协议的前提下合理使用。
