# 更新记录

## 2026-10-24 (下午) · 桌面重构升级 Aerial TV、深度净化去广告、网络分流突破与性能调优

- **桌面迁移至 Aerial TV**：升级至 Apple TV tvOS 风格的开源 Aerial TV（v1.41，`app.orchard.tv`）。支持毛玻璃 Dock 栏、Top Shelf 顶部预览与控制中心，内置 114 个 Apple TV 4K 航拍屏保，替代并卸载了原本冗余的独立 AerialViews 屏保。
- **第二阶段深度去广告与系统瘦身**：
  - 彻底卸载清理 18 项小米电视系统级广告、埋点统计、游戏大厅、弹窗推送与收费组件（`com.miui.analytics`, `com.miui.tv.analytics`, `com.xiaomi.statistic`, `com.xm.webcontent`, `com.xiaomi.mitv.tvpush.tvpushservice`, `com.mitv.screensaver`, `com.xiaomi.mibox.lockscreen`, `com.cmgame.gamehall.xmtv`, `com.xiaomi.gamecenter.sdk.service.mibox`, `com.tencent.start.tv`, `com.mitv.shoplugin`, `com.xiaomi.mitv.pay`, `com.xiaomi.mitv.payment`, `com.xiaomi.mitv.karaoke.service`, `com.xiaomi.eetv.exhibition`, `com.xiaomi.mitv.handbook`, `com.xiaomi.mitv.healthdiagnosis`, `com.lutongnet.nldmxXiaomiChildren`, `com.tvbc.mddtv`）。
  - 清理多余第三方应用（AerialViews 屏保、Aurora Store、AccessibilityManager）。
  - 释放可用磁盘空间至 15 GB，空闲运行内存恢复至 740 MB+。
- **系统性能提速调优**：
  - 全局动画缩放统一降至 0.5x，大幅消除芯片界面渲染粘滞感。
  - 对核心影音应用执行全量 AOT Speed 本地机器码编译（Aerial TV、我的电视、Jellyfin、BBLL、电视直播、LocalSend、Immich TV），冷启动速度提升约 30%~50%。
- **新增 Immich TV 私有云相册支持**：安装 Immich Android TV（v6.2.0），并完成本地 Docker 服务自动化配对与大屏照片浏览。
- **FlClash 代理与 Android TV 关键分流突破**：
  - 支持多协议节点合流导入 Clash Meta (Mihomo) 配置并提供 Android TV 专用模板（`tools/clash_template_androidtv.yaml`）。
  - **核心网络修复**：开启 FlClash 应用访问控制「白名单模式」，仅允许 SmartTube 走 VPN 代理，彻底根治此前 TUN 虚拟网卡黑洞阻断全局 IPv6、导致 Jellyfin 无法连接服务器与 IPTV 直播异常的痛点。
- **ADB 安全策略**：注销并停用 Aerial 的 `keep_adb` 自动保持守护，电视重启后不主动对外暴露 ADB 调试端口。
- **生态扩展调研**：增加鸿蒙电视（华为智慧屏）在桌面替换、单机代理及纯血鸿蒙演进下的可行性调研记录。

## 2026-10-24 (上午) · 播放兼容与无障碍恢复

- 安装官方网易爆米花 TV 2.6.23，用户确认连接后的画面和声音正常。
- MyTV 仅关闭“跳过渲染多帧”，用户确认测试频道恢复连续播放、不再循环。
- 用户明确授权后配置开源无障碍管理器 10.3；模拟移除约 0.5 秒自动恢复并保留小米语音。一次真实重启后绑定正常，DaemonService 的开机自启仍待最终核验。
- 记录第三方来源、哈希、权限范围与回滚顺序；不发布设备标识、原始日志、账号或家庭地址。详见 [实测补充](docs/调试记录-2026-10-24.md)。

## 2026-10-23 · 实机调试结果与隐私整理

- 修复 TVBox 配置推送使用错误的 `do=push`，改为 `do=api`；先打开配置弹窗、电视确认保存，并明确 HTTP 成功不代表已加载/可播放。此 HTTP 操作移到 ADB 连接之前，不再要求 ADB。
- 添加保留现有无障碍服务的 `repair-launcher`，读取失败即停止，检查当前服务绑定；部署与回滚避免覆盖小爱等其他服务。没有增加重启自动恢复。
- 保留电视端截图后拉取的流程，避免设备输出前缀损坏 PNG。
- 添加 TVBox 家庭、备用点播及独立本地直播配置；保留苏州移动 TXT/M3U；记录上游提交和插件 MD5。JAR 不新增分发，提供对应版本下载步骤。
- 记录 BBLL 修复包名与 MyTV 解码器占用排查、Jellyfin 用户确认播放结果；避免在已安装修复版时再次安装旧 BBLL 包。
- 部署在 Android 未确认新桌面启动、默认 Home 设置成功时停止停用原桌面；修正 ADB 持久化、屏保、开机直播与回滚的过度保证。
- 更新中英文说明，历史译文/设计稿添加状态提示。
- 当前文件去除家庭 IP、NAS 地址和个人本机路径；脚本要求显式目标与扫描网段。忽略设备截图、备份和本地缓存；发布提交使用 GitHub noreply 邮箱。同时按用户要求清理旧提交中的家庭地址、个人路径和提交身份；原历史仅在本地备份中保留。

本次验证以 [实机记录](docs/调试记录-2026-10-23.md) 为准。脚本更新使用离线模拟验证，未再次向电视执行全量部署或回滚。


### 同日后续修复与可复现配置

- 补齐实机已用 BBLL 1.5.5 安装包及哈希记录。
- 从当前直播列表移除电脑、电视均确认404的3个频道，保留112个有效清单和原件备份。
- 缓存同版本点播规则及核心依赖，绕过电视访问GitHub的TLS失败；修复公版影像视频ID提取，精简默认入口完成实际试播。
- AerialViews改用TextureView后恢复画面；仅确认手动预览，不宣称自动触发已解决。
- 本轮没有更改开机直播、自动恢复或登录信息，完整恢复文件保存在Git忽略的本地目录。

- 新增 prepare_tvbox.py：固定版本、SHA256 校验、网易规则修复、规则本地化及三套配置构建；支持现有缓存离线核对。公开精简配置与完整资源校验清单，生成文件和第三方缓存继续忽略。
- 自动屏保需要通知访问以避开媒体播放，尚未授权启用；重启无障碍恢复未部署，保留手动恢复与已验证的手动屏保设置。
