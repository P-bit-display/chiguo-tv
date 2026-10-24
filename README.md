# 🍎 赤果 (ChiGuo) · RedApple TV

<p align="center">
  <img src="https://img.shields.io/badge/Project-赤果%20ChiGuo-red?style=for-the-badge" alt="ChiGuo">
  <img src="https://img.shields.io/badge/Platform-Android%20TV-blue?style=for-the-badge" alt="Android TV">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT">
</p>

![赤果 ChiGuo](docs/banner.jpg)

[English](README.en.md) · **简体中文** · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [Русский](README.ru.md) · [Español](README.es.md)

面向红米/小米 Android 电视的桌面与影音配置工具。通过局域网 ADB 安装应用、调整部分系统设置，并提供 TVBox 配置与故障排查方法。无需 Root 或刷机；系统修改仍需先备份并逐项验证。

## 最新实测：2026-10-24

MiTV-MFTP0 / Android 9 / 固件 6129：

| 功能 | 本次确认的状态 |
| --- | --- |
| 极简桌面 | 升级至 **Aerial TV（v1.41）**，Apple TV tvOS 原生毛玻璃 Dock 栏、Top Shelf 顶部预览与控制中心，已写入系统默认 HOME |
| 航拍慢速屏保 | **Aerial TV 内置 114 个 Apple TV 4K 原生航拍屏保**；已卸载淘汰原独立 AerialViews 屏保 |
| 系统净化去广告 | 深度卸载 **18 项系统广告、埋点统计、游戏大厅与弹窗推送**，可用存储升至 15 GB，空闲内存升至 740 MB+ |
| 系统响应提速 | **全局动画缩放降至 0.5x**，核心应用（Aerial TV、我的电视、Jellyfin、BBLL、电视直播、LocalSend、Immich）**完成全量 AOT Speed 机器码预编译** |
| 私有云影院 | **Jellyfin** 保持公网 IPv6 双栈极速直连（Ping 17ms，海报墙与 4K 播放正常） |
| 电视相册大屏 | **Immich TV（v6.2.0）** 完成本地私有相册服务免密配对与大屏照片浏览 |
| 代理与流媒体 | **FlClash 突破性配置「应用访问控制 · 白名单模式」**，仅 SmartTube 走代理，彻底杜绝 TUN 虚拟网卡阻断全局 IPv6 与家庭影院冲突 |
| BBLL 哔哩哔哩 | 修复版 1.5.5（`com.V2.blb5`）正常解析高码率视频，解除 Wbi 鉴权限制 |
| 电视直播 IPTV | 苏州移动 IPTV 112 频道 HLS 清单稳定播放；关闭“跳过渲染多帧”后连续播放不再循环 |
| 网易爆米花 TV | 2.6.23 连接现有媒体库，画面与声音正常 |
| ADB 安全策略 | **关闭 Aerial `keep_adb` 自动保持守护**，重启后不主动对外暴露 5555 调试端口，杜绝内网暴露隐患 |

最新实机排查、网络冲突修复、分流模板与回滚步骤详见 [2026-10-24 调试记录](docs/调试记录-2026-10-24.md)。配合 Android TV 专用的 [FlClash 分流配置模板](tools/clash_template_androidtv.yaml) 使用。

**列表加载不等于播放成功。** 一个社区站点的抽测影片报错；不保证每个站点和频道可播。详细设置、已知限制及排查过程见 [实测记录](docs/调试记录-2026-10-23.md)。

本地第二轮修复还增加了规则缓存和精简默认入口，并已实际播出公版影像；完整配置保留备用，详见实测记录末节。构建方法、固定版本及校验清单一并公开，见 [TVBox 配置说明](tvbox/README.md)。

## 已经部署过的电视

按需使用辅助工具，避免为同步项目而重新执行全量部署：

```bash
./tv_helper.sh <电视IP> status
./tv_helper.sh <电视IP> screenshot
./tv_helper.sh <电视IP> nas <自己的Jellyfin服务器URL>
```

TVBox 本地频道、家庭和备用配置见 [导入步骤](tvbox/README.md)。配置导入完成后，使用时不需要电脑或 ADB 常驻。第三方站点与部分脚本仍依赖网络。

在 TVBox **设置 → 配置地址弹窗** 已打开时：

```bash
./tv_helper.sh <电视IP> push-tvbox 'clan://localhost/Download/ChiGuoTVBox_20261023/config-simple.json'
```

HTTP 返回成功只表示填写请求已提交，还要在电视核对点播、直播两个字段并按 **确定** 保存。此命令使用 TVBox 9978 服务，无需开启 ADB；其他 ADB 命令需先允许调试。

当前会话的 Projectivy 无障碍服务丢失时，可手动执行：

```bash
./tv_helper.sh <电视IP> repair-launcher
```

命令保留已有服务，包括小爱语音，并检查 Projectivy 是否绑定；不保证重启后持久化。

## 首次部署

需要 Bash、ADB（Android Platform Tools）、curl，以及扫描功能所需的 Python 3。电脑与电视在同一局域网，先在电视端允许 ADB 并确认授权。

```bash
./deploy.sh <电视IP> --lite
# 或安装全部扩展应用
./deploy.sh <电视IP> --apple-tv
```

`--pure-tv` 仅在本次部署末尾打开 MyTV，不代表建立了开机自启或不可退出的锁定模式。脚本会安装应用、清理部分缓存、禁用所列系统组件并切换桌面；不应将它当作只读检查。

仓库 APK 为历史打包快照，可能落后于实机修复版本。本地项目已将 `apks/BBLL.apk` 补齐为本次使用的 1.5.5 修复版，哈希见 `apks/BBLL.version.json`；已安装 `com.V2.blb5` 时脚本仍跳过重复安装。账号、NAS 与点播源均需单独配置，安装完成不等于功能验收完成。

如需扫描，显式设置自己网段的前三段，不内置家庭网络信息：

```bash
CHIGUO_SCAN_PREFIX=<自己的网段前三段> ./tv_helper.sh scan
CHIGUO_SCAN_PREFIX=<自己的网段前三段> ./deploy.sh auto --lite
```

部分小米固件提供 6095 HTTP 远控接口：

```bash
./tv_helper.sh <电视IP> open-settings
./tv_helper.sh <电视IP> apps
./tv_helper.sh <电视IP> key home
```

接口可用性取决于固件和网络。能打开设置不代表 ADB 已开启；需要在电视上确认。

## 恢复桌面

```bash
./restore.sh <电视IP>
```

恢复小米桌面、启用脚本列出的系统包并调整部分设置。仅移除 Projectivy 无障碍服务，保留其他服务。**不是出厂重置，也不是按历史快照完整还原。** 可选 `--uninstall-all` 会尝试卸载所列第三方应用；执行前阅读脚本及[回滚边界](docs/调试记录-2026-10-23.md#回滚边界)。

## 项目文件

- `deploy.sh`：首次部署；`tv_helper.sh`：日常检查和手动修复；`restore.sh`：桌面回滚。
- `tvbox/`：两套社区点播快照、独立本地直播配置、来源和插件校验信息。
- `suzhou_mobile.txt` / `.m3u`：当前112频道列表；原115频道列表已本地备份，可能受地区和运营商限制。
- `docs/调试记录-2026-10-23.md`：本次确认结果与未解决项。
- `apks/`：历史客户端快照；各第三方软件版权和许可归原作者。
- 根目录旧设计文档与其他语言译文保留作历史参考，功能状态以本页及最新实测记录为准。

调试截图、设备备份、个人服务器配置和本地插件缓存被忽略，不应提交。文档中的 `192.0.2.0/24` 是保留示例网段，不能直接作为真实设备地址。参见 [更新记录](CHANGELOG.md)。

## 许可与内容来源

项目自有代码按 [MIT](LICENSE) 发布；第三方应用、配置和插件遵循各自上游许可。本项目与小米、苹果及其他厂商无隶属关系。频道列表与社区配置不包含媒体文件，不保证内容授权、可用性或画质；请使用自己有权访问的服务。
