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
  <a href="README.md">简体中文</a> · 
  <b>繁體中文</b> · 
  <a href="README.ja.md">日本語</a> · 
  <a href="README.ru.md">Русский</a> · 
  <a href="README.es.md">Español</a>
</p>

<p align="center">
  <b>讓紅米/小米電視擁有 Apple tvOS 般極簡優雅體驗</b><br>
  <i>紅米 (Red) + 蘋果 (Apple) = 赤果 · 刪繁就簡，返璞歸真</i>
</p>

---

## 📖 專案簡介

**赤果 (ChiGuo)** 是一個面向 Android TV / 小米電視 / 紅米電視的開源自動化調優套件。無需 Root、不刷底層韌體、零變磚風險，利用 **AI Agent + 局域網 ADB 協議**，對電視系統進行深度資源釋放與背景輕量化，換裝極簡優雅的 **tvOS 風格桌面**，並打通 **開機直達電視直播、B站 4K、群暉 NAS 影院與多媒體中心**。

> 💡 **設計初心**：現在的智慧電視滿屏推薦資訊流、背景推送繁重，長輩想看電視節目往往要按十幾下遙控器。赤果透過自動化控制，讓電視回歸「通電即看、純淨極簡」的本質。

---

## 🔍 核心特性

- ⚡ **開機直達電視節目**：通電自動進入全屏電視直播，遙控器上下鍵切換頻道，保留長輩最習慣的操作模式。
- 🍏 **tvOS 極簡美學桌面**：採用經過社群長年檢驗的 Projectivy Launcher，大圓角動態卡片、高斯模糊毛玻璃背景，按 Home 鍵隨時呼出極簡主頁。
- 🍃 **背景輕量化與資源釋放**：停用冗餘的背景推送、商城服務與數據採集組件，徹底清理系統離線快取，記憶體（RAM）釋放達 40%~60%，老電視重獲絲滑。
- 🍿 **全能家庭影音生態**：
  - **嗶哩嗶哩 TV版 (BBLL)**：支援 4K 120Hz、杜比視界，彈幕流暢無干擾。
  - **私有家庭影院 (Jellyfin)**：直連群暉 NAS 局域網影音庫，呈現電影海報牆，晶片硬體直解。
  - **網路分流擴充 (FlClash TV版)**：電視遙控器方向鍵完美適配，支援基於規則的網路分流。
  - **海外高畫質影音 (SmartTube)**：4K/8K 杜比視界，免 GMS 谷歌框架運行，徹底去除片頭廣告。
  - **開源聚合播放器 (TVBox)**：輕量純淨播放核心，支援匯入自訂開源資料源。
  - **大屏黑膠音樂 (網易雲音樂 TV版)**：大屏黑膠唱片視覺設計與客廳氛圍音樂。
  - **Apple TV 4K 動態空拍螢幕保護程式 (AerialViews)**：閒置待機時輪播蘋果官方 4K 空拍超清動態桌布。
  - **局域網檔案互傳 (LocalSend)**：跨平台局域網檔案閃傳，電腦/手機無線向電視發送檔案。
- 🛡️ **工業級防軟磚與系統加固**：具備桌面預檢自拉起、低記憶體防殺白名單（Anti-LMK），100% 保留遙控器小愛同學語音鍵與 HDMI-CEC 訊號源控制。
- 🔄 **100% 無損隨時還原**：配套提供 `restore.sh` 腳本，一條命令瞬間復原小米官方原廠出廠狀態。

---

## 🛠️ 雙模式一鍵運行

1. 確保電腦與電視處於同一個 Wi-Fi 局域網。
2. 電視開啟【ADB 除錯】（設定 -> 關於 -> 連按版本號 5 次開啟開發者選項 -> 允許 ADB 除錯）。
3. 終端執行部署腳本（按家庭場景二選一）：

### 選項 A：全能雙模（年輕人 + 長輩通吃，預設推薦）
```bash
./deploy.sh <你的電視IP>
```
* **體驗**：開機無廣告直達電視直播，按遙控器【Home 鍵】秒切 Apple TV 極簡桌面，隨時暢享 B站 4K、群暉 NAS 影院與海外串流媒體。

### 選項 B：純看電視·長輩鎖定模式（專治長輩誤觸）
```bash
./deploy.sh <你的電視IP> --pure-tv
```
* **體驗**：**徹底鎖定電視直播！** 電視通電就是電視畫面，按 Home 鍵或返回鍵只會調出節目表，**絕對不會跳出到任何智慧系統或設定選單**。

---

### 🛡️ 一鍵出廠還原
如需恢復小米官方出廠桌面與出廠設定：
```bash
./restore.sh <你的電視IP>
```

---

## ⚖️ 免責聲明

1. 本專案為開源技術愛好者對 Android TV 系統底層機制的調優研究成果，僅供個人技術交流與合法設備維護使用。
2. 使用者對個人購買的電視硬體享有合法的排他性支配權與軟體設定自主權。
3. 本專案不提供、不製作、不傳播、不儲存任何受版權保護的商業音視頻資源；文中所提商標版權歸各自原始權利人所有。
