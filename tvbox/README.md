# TVBox 本地配置

2026-10-23 调试快照，适配俊版 TVBox `com.github.tvbox.osc.jun`（20260924-2341）。

| 文件 | 用途 |
| --- | --- |
| `config-simple.json` | 默认精简入口：网易公版、新片预告、本地视频，共 3 项 |
| `config-family.json` | 家庭点播，153 个站点 |
| `config-backup.json` | 备用点播，49 个站点 |
| `live-local.json` | 独立直播配置，引用电视本地频道 TXT |
| `../suzhou_mobile.txt` / `.m3u` | 112 个频道；原 115 个中有 3 个经电脑和电视确认 HTTP 404 后移除 |
| `upstream.json` | 固定上游提交、插件路径及 MD5/SHA256 |
| `runtime-cache-manifest.json` | 41 份规则与依赖的原始及修复后 SHA256 |
| `channel-health.json` | 本次频道检查统计，未包含设备地址 |

精简配置中的网易公版影像已实际播放出画面；另两项未逐项验证。家庭和备用配置保留可供尝试，但列表加载不代表可以播放。直播抽测一路出画面，其余仅核对 HLS 清单；地区、运营商和上游状态均会影响可用性。

## 1. 构建本地文件包

需要 Python 3.9 或更高版本。在项目根目录执行：

```bash
python3 tools/prepare_tvbox.py --output tvbox/build
```

输出目录必须不存在或为空，工具不会覆盖已有文件。工具下载固定提交的规则及两份插件，逐份校验 SHA256，修复网易公版影像的视频 ID 提取，再生成三套配置。网络下载失败或校验不符即停止，不输出半成品。

规则及核心依赖改用电视自身的 HTTP 文件服务，避免本次遇到的电视访问 GitHub TLS 失败。媒体及部分站点配置仍需网络；这不是离线媒体库。上游缺失的 `js/Anime1动畫.js` 未被伪造或标记为可用。

如已有完整本地文件包，可离线重建并校验：

```bash
python3 tools/prepare_tvbox.py --cache /path/to/existing-bundle --output /path/to/new-bundle
```

缓存目录应包含 `runtime/` 和两份 JAR。完整离线构建及自动测试已通过；不同网络环境下的下载成功率未保证。

## 2. 复制到电视

电视端允许 ADB 后，将 `<电视IP>` 换成实际地址：

```bash
adb connect <电视IP>:5555
adb -s <电视IP>:5555 shell mkdir -p /sdcard/Download/ChiGuoTVBox_20261023
adb -s <电视IP>:5555 push tvbox/build/. /sdcard/Download/ChiGuoTVBox_20261023/
```

也可用 LocalSend 或 U 盘复制，保持文件夹层级及目标目录不变。ADB 只用于复制、安装和调试，播放不需要电脑常驻。

## 3. 填写并保存

打开 TVBox **设置 → 配置地址弹窗**，允许必要的存储访问。

点播：

```text
clan://localhost/Download/ChiGuoTVBox_20261023/config-simple.json
```

直播：

```text
clan://localhost/Download/ChiGuoTVBox_20261023/live-local.json
```

在电视按 **确定**，等首页完成加载后再操作，将“下次进入”设为“点播”。

要保留家庭及备用入口，分别将点播改为同目录 `config-family.json`、`config-backup.json` 并保存一次，随后切回 `config-simple.json`。三者会出现在 **设置 → 配置历史** 中；直播字段保持独立的 `live-local.json`。

也可在配置弹窗打开时，从电脑执行：

```bash
./tv_helper.sh <电视IP> push-tvbox 'clan://localhost/Download/ChiGuoTVBox_20261023/config-simple.json'
```

此命令使用 TVBox 9978 服务，无需 ADB，但 TVBox 必须运行。返回成功仅代表填写请求被接受，仍需核对两个地址并按 **确定**。点播接口为 `do=api`，单独填写直播为 `do=liveApi`。

## 来源与边界

上游：[qist/tvbox](https://github.com/qist/tvbox)，固定提交见清单。本项目公开配置、版本清单及构建工具，不新增分发第三方 JAR 或整套规则缓存。下载和使用受各资源上游条款约束，本项目 MIT 许可不改变第三方许可。哈希用于完整性核对，不代表第三方代码安全审计。

测试：`python3 -m unittest discover -s tests -p 'test_prepare_tvbox.py'`；脚本兼容性检查：`bash tests/smoke.sh`。
