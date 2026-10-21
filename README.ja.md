# 🍎 ChiGuo (赤果) · RedApple TV

<p align="center">
  <img src="https://img.shields.io/badge/Project-ChiGuo%20RedApple-red?style=for-the-badge" alt="Project">
  <img src="https://img.shields.io/badge/Style-Apple%20tvOS%20Aesthetics-black?style=for-the-badge&logo=apple" alt="Apple tvOS">
  <img src="https://img.shields.io/badge/Platform-Android%20TV%20%7C%20MIUI%20TV%20%7C%20HyperOS-blue?style=for-the-badge&logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/Driven%20by-AI%20Agent-purple?style=for-the-badge&logo=openai" alt="AI Agent">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/P-bit-display/chiguo-tv@main/docs/banner.jpg" alt="ChiGuo · RedApple TV" width="100%">
</p>

<p align="center">
  <a href="README.en.md">English</a> · 
  <a href="README.md">简体中文</a> · 
  <a href="README.zh-TW.md">繁體中文</a> · 
  <b>日本語</b> · 
  <a href="README.ru.md">Русский</a> · 
  <a href="README.es.md">Español</a>
</p>

<p align="center">
  <b>Redmi / Xiaomi スマートテレビを Apple tvOS 風の超高速ミニマル体験へ</b><br>
  <i>Redmi (赤) + Apple (果実) = 赤果 (ChiGuo) · 無駄を削ぎ落とし、美しく純粋なテレビへ</i>
</p>

---

## 📖 プロジェクト概要

**赤果 (ChiGuo)** は、Android TV / Xiaomi TV / Redmi TV 向けのオープンソース自動チューニングツールキットです。Root化やブートローダーのアンロック、文鎮化のリスクは一切なく、**AI Agent + Wi-Fi ADB** を活用して、テレビの起動広告やプリインストールされた不要なサービスを完全に停止し、洗練された **tvOS スタイルのミニマルランチャー** へと生まれ変わらせます。

---

## 🔍 主な特徴

- ⚡ **起動後即ライブTV再生**：起動時の広告を完全に排除し、電源オンと同時にフルスクリーンでテレビ放送を開始。リモコンの上下ボタンで即座に選局可能。
- 🍏 **Apple tvOS 風ミニマルデザイン**：定評のある Projectivy Launcher を採用。角丸カードUI、ダイナミックなすりガラス（ブラー）効果、ホームボタン一つで洗練されたドックを呼び出し。
- 🍃 **システム軽量化とキャッシュ完全消去**：不要な広告やテレメトリサービスを停止し、`/sdcard` 内に蓄積されたオフライン広告キャッシュも完全除去。RAM消費を 40〜60% 削減。
- 🍿 **充実のメディアエコシステム**：
  - **SmartTube (広告なし YouTube)**：4K/8K 60fps HDR再生、SponsorBlock対応、広告ブロック、Googleサービス不要。
  - **Jellyfin (ホームシアター)**：Synology NAS などのローカルメディアサーバーと直接接続し、美しいポスターウォールとハードウェア再生を実現。
  - **FlClash (TV専用プロキシ)**：リモコンの十字キー操作に完全対応したネットワークルーティングツール。
  - **AerialViews (4K 空撮スクリーンセーバー)**：Apple TV 同様の美しい超高精細4K空撮映像をスタンバイ時に自動再生。
  - **LocalSend**：PCやスマホからテレビへワイヤレスでファイルやAPKを高速転送。
- 🛡️ **堅牢な安全設計**：ランチャー切り替え前の事前稼働テスト（ソフトブロック防止）、メモリキラーからの保護、純正リモコン機能の100%保持。
- 🔄 **いつでも1クリックで純正復元**：`restore.sh` スクリプトにより、いつでも3秒で工場出荷時の純正状態へ戻せます。

---

## 🛠️ ワンクリック実行（選べる2つのモード）

1. PCとテレビが同一の Wi-Fi / LAN に接続されていることを確認します。
2. テレビ側で「開発者向けオプション → ADBデバッグを許可」を有効にします。
3. ターミナルからスクリプトを実行します：

### モード A：デュアルモード（推奨・テレビ＋スマート機能）
```bash
./deploy.sh <テレビのIPアドレス>
```

### モード B：純粋テレビ専用モード（高齢者・誤操作防止）
```bash
./deploy.sh <テレビのIPアドレス> --pure-tv
```
* ホームボタンを押しても番組表が出るのみで、複雑な設定画面やランチャーへ抜け出すことがなく、従来のテレビ同様に安心して使用できます。

---

### 🛡️ 工場出荷状態への復元
```bash
./restore.sh <テレビのIPアドレス>
```

---

## ⚖️ 免責事項

1. 本プロジェクトは個人の研究および端末最適化を目的としたオープンソースツールです。
2. ユーザーは合法的に所有するハードウェアに対して排他的な支配権を有します。
3. 記載されている商標（Xiaomi, Apple, tvOS など）は技術的互換性の説明のためにのみ引用されており、各権利者に帰属します。
