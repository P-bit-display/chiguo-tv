# 📺 CleanYourTV-Agent：让红米/小米电视秒变 Apple TV

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20TV%20%7C%20MIUI%20TV%20%7C%20HyperOS-blue?style=for-the-badge&logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/Style-Apple%20tvOS-black?style=for-the-badge&logo=apple" alt="Apple tvOS">
  <img src="https://img.shields.io/badge/Driven%20by-AI%20Agent%20%28Claude%20%2F%20Antigravity%29-purple?style=for-the-badge&logo=openai" alt="AI Agent">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

> **🚀 灵感源自 CleanYourTV，专为中国家庭与极客打造**。无需 Root、不刷机、不拆机、零变砖风险，利用 **AI Agent + 局域网 ADB**，一键深度去除电视开机广告、粉碎内置臃肿服务、开机秒播央视/卫视直播，打造极简流畅的 **Apple TV (tvOS) 桌面**，并深度打通 **B站 4K、群晖 NAS、海外 YouTube、网易云音乐与电视专属 Clash**！

---

## 🔍 核心特性与亮点

- ⚡ **开机秒进电视直播**：通电即播央视/卫视 4K 直播，老人长辈 0 学习成本，遥控器上下键丝滑切台。
- 🍏 **Apple TV (tvOS) 极简桌面**：大圆角拟真卡片、高斯模糊动态虚化壁纸、按 Home 键秒切主页，彻底告别原厂瀑布流商业广告。
- 🛡️ **深层广告与离线视频粉碎**：停用 9 大官方广告与遥测服务，并物理清理 `/sdcard` 离线广告视频缓存池，断网也绝不播广告。
- 🍿 **全能家庭影音生态**：
  - **B站 4K 杜比 (BBLL)**：4K 120Hz、杜比视界、弹幕丝滑无开屏广告。
  - **私有家庭影院 (Jellyfin)**：直连群晖 NAS，自动刮削超清电影海报墙，4K 芯片硬件直解。
  - **全网免费聚合 (TVBox)**：内置海外/国内高速线路，院线大片免会员秒搜秒播。
  - **无广告 YouTube (SmartTube)**：4K/8K 杜比视界，彻底屏蔽贴片广告，免装 Google 框架。
  - **电视专属科学上网 (FlClash TV)**：遥控器方向键完美选节点，智能分流（国内直播直连，海外走代理）。
  - **Apple TV 4K 航拍屏保 (AerialViews)**：空间站俯瞰地球、全球地标慢速超清动态屏保。
  - **网易云音乐 TV 版**：大屏黑胶唱片视觉与氛围空间。
  - **局域网无线互传 (LocalSend)**：Mac/手机免 U 盘无线推送安装包与订阅配置。
- 🔒 **红蓝军 10 轮推演加固**：防软砖前置自检、防后台误杀白名单（Anti-LMK）、100% 保留小爱同学语音键与 HDMI-CEC 信号源切换。
- 🔄 **100% 随时一键还原**：提供 `restore.sh` 应急通道，一条命令瞬间复原小米官方原厂出厂状态。

---

## 🆚 与 CleanYourTV 官方原版对比

| 对比维度 | CleanYourTV (GitHub 原版) | CleanYourTV-Agent (本项目) |
| :--- | :--- | :--- |
| **生态面向** | 纯欧美流媒体（Netflix, Prime Video, YouTube） | **中国家庭全场景**（央视卫视直播、B站4K、群晖NAS、网易云、TVBox、Clash） |
| **开机看电视** | ❌ 不支持（只能进桌面再点应用） | ✅ **原生完美支持**（开机直接起播央视/卫视，按 Home 键才退回桌面） |
| **桌面体系** | 自研轻量启动器（修改需改代码重新编译） | **成熟的 Projectivy Launcher (tvOS 拟真版)**（动态毛玻璃、焦点放大、自启动引擎） |
| **科学上网** | ❌ 无方案 | ✅ **内置 FlClash TV 遥控器专属版**（大屏高亮光标导航） |
| **去广告深度** | 仅做基础命令停用 | **包停用 + 物理粉碎离线广告缓存池**（杜绝断网播广告） |
| **防软砖设计** | 弱（直接停用系统桌面） | **强**（前置拉起新桌面健康自检，验证通过后才切换） |
| **安全性** | 提倡完成后关闭 ADB 端口 | **完全吸收采纳**（提供完工物理关门指导） |

---

## 🤖 玩法一：交给你的 AI 编程助手（Claude Code / Cursor / Agent）

如果你在电脑上使用 [Claude Code](https://claude.com/product/claude-code)、Cursor 或其他具备终端权限的 AI Agent：

1. 电视开启【开发者选项 -> 允许 ADB 调试】。
2. 将本项目中的 [`PROMPT.md`](PROMPT.md) 内容直接复制发送给你的 AI Agent。
3. 坐等 AI Agent 自动探测局域网电视、一键推送安装并完成全部优化！

---

## 🛠️ 玩法二：手动一键运行

1. 确保 Mac / PC 与电视处于同一个 Wi-Fi 局域网。
2. 电视开启【ADB 调试】（设置 -> 关于 -> 连按系统版本号 5 次开启开发者选项 -> 允许 ADB 调试）。
3. 终端直接运行一键部署脚本：
   ```bash
   ./deploy.sh <你的电视IP>
   ```
   *(不填 IP 默认自动探测连接)*

### 🛡️ 一键出厂还原（后悔药）
如果任何时候需要保修或恢复小米官方出厂系统：
```bash
./restore.sh <你的电视IP>
```
3 秒内完整解冻全部官方组件并切回官方桌面，无任何后遗症。

---

## 🗂️ 目录结构说明

```
├── apks/                         # 10 大核心生态应用官方安装包
│   ├── ProjectivyLauncher.apk    # Apple TV 风格极简桌面 (含 tvOS 拟真卡片与壁纸)
│   ├── MyTV.apk                  # 开机即播电视直播 App (全平台兼容版，秒看央视/卫视)
│   ├── Clash.apk                 # 电视遥控器专属版科学上网工具 (FlClash)
│   ├── SmartTube.apk             # YouTube 终极电视版 (免广告 / 4K / 免 GMS)
│   ├── BBLL.apk                  # 哔哩哔哩 TV版 (4K/杜比视界/无开屏广告)
│   ├── Jellyfin.apk              # 个人家庭影院 (直连群晖 NAS 影音库)
│   ├── TVBox.apk                 # 全网免费影视聚合 (内置奈飞/迪士尼专线)
│   ├── NetEaseMusic.apk          # 网易云音乐 TV 官方大屏黑胶唱片版
│   ├── AerialViews.apk           # Apple TV 4K 同款全球动态航拍屏保
│   └── LocalSend.apk             # 局域网无线极速文件闪传
├── deploy.sh                     # 🚀【一键自动化部署脚本】
├── restore.sh                    # 🛡️【一键还原脚本】(随时秒回小米出厂系统)
├── PROMPT.md                     # 🤖【给 AI Agent 的标准化操作提示词】
├── redmi_tv_apple_system_ultimate_spec.md # 终极系统技术架构规范
├── redmi_tv_red_blue_review.md   # 🔴🔵 红蓝军 10 轮严苛攻防对抗审查记录
└── redmi_tv_test_cases_and_risks.md       # 14 项全生命周期测试用例
```

---

## 🏷️ 热门搜索提示词 (SEO Keywords)

`红米电视去广告` · `小米电视替换桌面` · `CleanYourTV 中文版` · `电视版 Agent` · `Claude Code 电视刷机` · `Apple TV 桌面` · `tvOS for Android TV` · `红米电视开机直达直播` · `电视看B站4K杜比` · `电视端Clash遥控器版` · `电视安装Jellyfin直连群晖` · `SmartTube电视免广告` · `小米电视澎湃OS HyperOS 换桌面` · `Projectivy Launcher 小米电视` · `电视ADB一键精简`

---

## 📄 开源许可

本项目遵循 [MIT License](LICENSE) 开源协议。
