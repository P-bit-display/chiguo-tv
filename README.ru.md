> **2026-10-23 status update:** This translation contains historical feature descriptions. Boot-to-live-TV, persistent ADB/accessibility, and automatic screensaver playback are not verified. See the updated [English README](README.en.md) or [简体中文 README](README.md) for current behavior.

# 🍎 ChiGuo (RedApple TV)

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
  <a href="README.ja.md">日本語</a> · 
  <b>Русский</b> · 
  <a href="README.es.md">Español</a>
</p>

<p align="center">
  <b>Превратите телевизоры Redmi и Xiaomi в минималистичный интерфейс в стиле Apple tvOS</b><br>
  <i>Redmi (Красный) + Apple (Яблоко) = ChiGuo (赤果) · Чисто, быстро и без рекламы</i>
</p>

---

## 📖 О проекте

**ChiGuo (赤果)** — это инструмент автоматической оптимизации для телевизоров на Android TV, Xiaomi TV и Redmi TV. Без root-прав, разблокировки загрузчика и риска окирпичивания, используя **AI Agent и локальный Wi-Fi ADB**, проект полностью отключает встроенную рекламу и телеметрию, заменяет перегруженный интерфейс на элегантный **лаунчер в стиле Apple tvOS** и настраивает мгновенный запуск прямого эфира, SmartTube, Jellyfin и домашний кинотеатр.

---

## 🔍 Основные возможности

- ⚡ **Мгновенный запуск ТВ-вещания**: Включение без рекламных заставок сразу в полноэкранное ТВ. Переключение каналов кнопками вверх/вниз на пульте.
- 🍏 **Минимализм Apple tvOS**: На базе проверенного Projectivy Launcher: карточки с закругленными углами, эффект матового стекла, плавное меню Dock.
- 🍃 **Глубокая очистка и удаление рекламы**: Отключение телеметрии и сервисов рекомендаций. Очистка скрытого кэша видеорекламы в `/sdcard`, освобождение 40–60% оперативной памяти.
- 🍿 **Мультимедийная экосистема**:
  - **SmartTube (YouTube для ТВ)**: 4K/8K 60fps HDR, встроенный SponsorBlock, полное отсутствие рекламы, работа без Google-сервисов.
  - **Jellyfin (Домашний кинотеатр)**: Прямое подключение к NAS (Synology), постеры фильмов, аппаратное ускорение.
  - **FlClash (Прокси для ТВ)**: Полная поддержка навигации стрелками пульта ДУ и маршрутизация трафика.
  - **AerialViews (4K заставки Apple TV)**: Фирменные 4K аэросъемки Земли и мировых столиц в режиме ожидания.
  - **LocalSend**: Беспроводная передача файлов и APK с компьютера/смартфона на ТВ без флешек.
- 🛡️ **Защита от сбоев**: Проверка стабильности перед сменой лаунчера, защита от выгрузки из ОЗУ (Anti-LMK), 100% сохранение голосового поиска и HDMI-CEC.
- 🔄 **Откат в один клик**: Скрипт `restore.sh` восстанавливает стандартную прошивку Xiaomi за 3 секунды.

---

## 🛠️ Запуск в один клик (Два режима)

1. Убедитесь, что ПК и ТВ подключены к одной локальной сети Wi-Fi.
2. Включите на ТВ режим разработчика и **Отладку по ADB**.
3. Запустите скрипт установки:

### Вариант A: Двойной режим (Рекомендуемый)
```bash
./deploy.sh <IP_АДРЕС_ТВ>
```
* Прямой запуск ТВ-эфира + открытие элегантного рабочего стола по кнопке **Home**.

### Вариант B: Режим «Только ТВ» (Для пожилых людей)
```bash
./deploy.sh <IP_АДРЕС_ТВ> --pure-tv
```
* Полная блокировка: кнопки пульта не выходят в меню, телевизор работает как классический телеприемник без лишних меню.

---

### 🛡️ Восстановление заводских настроек
```bash
./restore.sh <IP_АДРЕС_ТВ>
```

---

## ⚖️ Отказ от ответственности

1. Проект создан исключительно в исследовательских и образовательных целях для личной настройки устройств.
2. Пользователь обладает исключительными правами на владение и настройку своего оборудования.
3. Упомянутые товарные знаки (Xiaomi, Apple, tvOS) принадлежат их законным правообладателям.
