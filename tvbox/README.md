# TVBox 本地配置

这是 2026-10-23 调试使用的配置快照，适配本次安装的俊版 TVBox `com.github.tvbox.osc.jun`（20260924-2341）。

| 文件 | 用途 |
| --- | --- |
| `config-family.json` | 家庭点播，153 个站点，来源 qist/tvbox 的 jsm.json |
| `config-backup.json` | 备用点播，49 个站点，来源 qist/tvbox 的 fty.json |
| `live-local.json` | 独立直播配置，引用电视自身的本地频道 TXT |
| `../suzhou_mobile.txt` / `.m3u` | 用户本地苏州移动源：115 个去重频道、5 个分组 |
| `upstream.json` | 上游版本、插件下载地址和 MD5 |

两套点播配置均保留本地直播入口。直播源可能受地区、运营商和网络状态限制；频道识别成功不表示逐台可播。社区站点只验证过列表加载，一个抽测影片播放报错，未保证全部可用。此快照不自动更新。

## 1. 准备插件

仓库不新增分发第三方 JAR 二进制。两份配置引用电视本地的 `qist-spider.jar`、`qist-fan.jar`，需下载对应版本；地址固定到上游提交，避免分支变动引起校验不一致。

在项目根目录执行：

```bash
curl -fL --connect-timeout 5 --max-time 120 'https://raw.githubusercontent.com/qist/tvbox/94e797a1daf727c51a8a61c91388dd52a29f0057/jar/spider.jar' -o tvbox/qist-spider.jar
curl -fL --connect-timeout 5 --max-time 120 'https://raw.githubusercontent.com/qist/tvbox/94e797a1daf727c51a8a61c91388dd52a29f0057/jar/fan.txt' -o tvbox/qist-fan.jar
```

核对 MD5：`qist-spider.jar` 为 `f302b3d8b3b84ad823a720966d9a1dfc`；`qist-fan.jar` 为 `654fb7dcb0aeaaea7dba0e662395f38e`。macOS 可用 `md5 tvbox/*.jar`，Linux 可用 `md5sum tvbox/*.jar`。两者实际均为 ZIP/JAR 格式，下载错误页不可用。

## 2. 复制到电视

电视端允许 ADB 后，将 `<电视IP>` 换成实际地址：

```bash
adb connect <电视IP>:5555
adb -s <电视IP>:5555 shell mkdir -p /sdcard/Download/ChiGuoTVBox_20261023
adb -s <电视IP>:5555 push tvbox/config-family.json tvbox/config-backup.json tvbox/live-local.json tvbox/qist-spider.jar tvbox/qist-fan.jar suzhou_mobile.txt /sdcard/Download/ChiGuoTVBox_20261023/
```

也可用 LocalSend 或 U 盘复制到同一目录。ADB 只用于安装/复制/调试，播放时不需常驻连接。

## 3. 填写并保存

打开 TVBox **设置 → 配置地址弹窗**，允许必要的存储访问。

点播：

```text
clan://localhost/Download/ChiGuoTVBox_20261023/config-family.json
```

直播：

```text
clan://localhost/Download/ChiGuoTVBox_20261023/live-local.json
```

按电视上的 **确定**。等首页完成加载后再操作，首次初始化可能需要几十秒。将“下次进入”设为“点播”。

备用配置导入：将点播改为 `clan://localhost/Download/ChiGuoTVBox_20261023/config-backup.json` 并保存，随后切回家庭配置。两者会出现在 **设置 → 配置历史** 中；注意保持直播字段指向独立的 `live-local.json`。

也可在配置弹窗打开时，从电脑执行：

```bash
./tv_helper.sh <电视IP> push-tvbox 'clan://localhost/Download/ChiGuoTVBox_20261023/config-family.json'
```

该命令使用 TVBox 的 9978 HTTP 服务，无需开启 ADB；但 TVBox 必须运行。返回 `ok` 只代表填写请求被接受，需在电视核对两个地址并按 **确定**。如需网页单独填写直播，使用 `http://<电视IP>:9978/` 的直播配置入口（`do=liveApi`）。

## 版本与来源

点播快照来自 [qist/tvbox](https://github.com/qist/tvbox)，本项目仅将相对资源地址展开、替换插件为本地路径、替换直播为已有本地源。发布时将 qist 原始资源地址固定到已核对的上游提交。JSON 与 JAR 解析脚本仍依赖各自站点服务，整个点播功能并非离线媒体库。

本地调试目录 `tvbox-sources-20261023/` 仍保留电视当时使用的完整文件，不纳入 Git。此目录的插件下载与使用由各自上游条款约束，本项目的 MIT 许可不改变第三方资源许可。
