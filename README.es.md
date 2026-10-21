# 🍎 ChiGuo (RedApple TV)

<p align="center">
  <img src="https://img.shields.io/badge/Project-ChiGuo%20RedApple-red?style=for-the-badge" alt="Project">
  <img src="https://img.shields.io/badge/Style-Apple%20tvOS%20Aesthetics-black?style=for-the-badge&logo=apple" alt="Apple tvOS">
  <img src="https://img.shields.io/badge/Platform-Android%20TV%20%7C%20MIUI%20TV%20%7C%20HyperOS-blue?style=for-the-badge&logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/Driven%20by-AI%20Agent-purple?style=for-the-badge&logo=openai" alt="AI Agent">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

<p align="center">
  <a href="README.en.md">English</a> · 
  <a href="README.md">简体中文</a> · 
  <a href="README.zh-TW.md">繁體中文</a> · 
  <a href="README.ja.md">日本語</a> · 
  <a href="README.ru.md">Русский</a> · 
  <b>Español</b>
</p>

<p align="center">
  <b>Transforma televisores Redmi y Xiaomi en una experiencia minimalista al estilo Apple tvOS</b><br>
  <i>Redmi (Rojo) + Apple (Manzana) = ChiGuo (赤果) · Puro, rápido y sin anuncios</i>
</p>

---

## 📖 Introducción

**ChiGuo (赤果)** es una suite de optimización automatizada para televisores con Android TV, Xiaomi TV y Redmi TV. Sin root, sin desbloqueo de bootloader y sin riesgos de brickeo, aprovecha **Agentes de IA y ADB por Wi-Fi** para eliminar el bloatware del sistema, desactivar la publicidad y desplegar un **lanzador minimalista estilo Apple tvOS**, integrando televisión en vivo directa, SmartTube, Jellyfin y cine en casa.

---

## 🔍 Características Principales

- ⚡ **Inicio directo a TV en vivo**: Encendido sin publicidad directo a los canales de televisión. Cambio de canal rápido con las flechas del mando.
- 🍏 **Estética Minimalista Apple tvOS**: Diseñado sobre Projectivy Launcher, con tarjetas de esquinas redondeadas, desenfoque dinámico y dock limpio al pulsar Home.
- 🍃 **Limpieza Profunda y Eliminación de Anuncios**: Desactiva la telemetría y el software innecesario. Elimina la memoria caché oculta de vídeos publicitarios en `/sdcard`, liberando del 40% al 60% de memoria RAM.
- 🍿 **Ecosistema Multimedia Completo**:
  - **SmartTube (YouTube para TV)**: 4K/8K 60fps HDR, SponsorBlock integrado, sin anuncios y sin necesidad de servicios de Google.
  - **Jellyfin (Cine en casa)**: Conexión directa a servidores NAS locales (Synology), carátulas de películas y aceleración por hardware.
  - **FlClash (Cliente Proxy para TV)**: Navegación 100% adaptada al mando a distancia y enrutamiento inteligente de tráfico.
  - **AerialViews (Salvapantallas Apple TV 4K)**: Vídeos aéreos en 4K de la Tierra y ciudades del mundo durante el modo reposo.
  - **LocalSend**: Envío inalámbrico de archivos y APKs desde tu ordenador o móvil al televisor sin memorias USB.
- 🛡️ **Seguridad Blindada**: Verificación previa del lanzador antes del cambio para evitar bloqueos, protección contra el cierre de memoria (Anti-LMK) y conservación del 100% de los controles por voz y HDMI-CEC.
- 🔄 **Reversibilidad Total**: Script `restore.sh` que devuelve el televisor a su estado original de fábrica en 3 segundos.

---

## 🛠️ Ejecución en un Clic (Dos Modos Disponibles)

1. Conecta tu ordenador y televisor a la misma red Wi-Fi o cable.
2. Activa en el televisor las Opciones de Desarrollador y la **Depuración por ADB**.
3. Ejecuta el script desde tu terminal:

### Opción A: Modo Dual (Recomendado para toda la familia)
```bash
./deploy.sh <IP_DEL_TELEVISOR>
```
* Inicio directo a televisión en vivo + acceso al elegante escritorio de Apple pulsando **Home**.

### Opción B: Modo Exclusivo de TV (Para personas mayores)
```bash
./deploy.sh <IP_DEL_TELEVISOR> --pure-tv
```
* Bloqueo total: el mando nunca sale a menús complejos ni ajustes; el televisor funciona como una televisión clásica tradicional.

---

### 🛡️ Restauración a Estado de Fábrica
```bash
./restore.sh <IP_DEL_TELEVISOR>
```

---

## ⚖️ Aviso Legal

1. Proyecto creado exclusivamente con fines educativos, de investigación técnica y mantenimiento de dispositivos personales.
2. El usuario ejerce su legítimo derecho de propiedad sobre su dispositivo.
3. Las marcas mencionadas (Xiaomi, Apple, tvOS) pertenecen a sus respectivos propietarios legales.
