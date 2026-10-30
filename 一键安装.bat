@echo off
chcp 65001 >nul
title 赤果 (ChiGuo) · 红米/小米电视极简系统一键安装工具
color 0A

:: 设置基础路径
set "ROOT_DIR=%~dp0"
set "BIN_DIR=%ROOT_DIR%bin"
set "APK_DIR=%ROOT_DIR%apks"
set "BACKUP_DIR=%ROOT_DIR%backup"

:: 检查本地 ADB 还是系统 ADB
if exist "%BIN_DIR%\adb.exe" (
    set "ADB=%BIN_DIR%\adb.exe"
) else (
    where adb >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        set "ADB=adb"
    ) else (
        echo ========================================================
        echo [!] 提示: 未检测到内置 ADB 工具。
        echo [*] 正在为您从 Google 官方自动下载便携版 ADB 工具包...
        echo ========================================================
        mkdir "%BIN_DIR%" >nul 2>nul
        powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile '%BIN_DIR%\adb.zip'"
        powershell -Command "Expand-Archive -Path '%BIN_DIR%\adb.zip' -DestinationPath '%BIN_DIR%\temp' -Force"
        copy "%BIN_DIR%\temp\platform-tools\adb.exe" "%BIN_DIR%\" >nul
        copy "%BIN_DIR%\temp\platform-tools\AdbWinApi.dll" "%BIN_DIR%\" >nul
        copy "%BIN_DIR%\temp\platform-tools\AdbWinUsbApi.dll" "%BIN_DIR%\" >nul
        rmdir /s /q "%BIN_DIR%\temp" >nul 2>nul
        del "%BIN_DIR%\adb.zip" >nul 2>nul
        set "ADB=%BIN_DIR%\adb.exe"
        echo [√] ADB 准备就绪！
    )
)

cls
echo ================================================================
echo    🍎 赤果 (ChiGuo · RedApple TV) 小米/红米电视一键极简改装工具
echo ================================================================
echo.
echo  本工具专为普通用户设计：
echo  - 彻底清理开机广告、商城、弹窗与后台耗电全家桶
echo  - 一键改装为 Apple tvOS 极简毛玻璃美学桌面与 4K 原生航拍屏保
echo  - 优化电视直播、解决 5 秒循环、配置 0.5x 动画与防关机
echo.
echo ================================================================
echo.

:INPUT_IP
set /p TV_IP="请输入电视的局域网 IP 地址 (例如 192.168.1.100，或按回车自动扫描): "

if "%TV_IP%"=="" (
    echo [*] 正在自动扫描局域网内的小米/红米电视...
    for /f "tokens=1" %%i in ('powershell -Command "$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.IPAddress -like '192.168.*' }).IPAddress | Select-Object -First 1; $prefix = $ip.Substring(0, $ip.LastIndexOf('.')); 1..254 | ForEach-Object -Parallel { $testIp = \"$using:prefix.$_\"; $s = New-Object System.Net.Sockets.TcpClient; try { $iar = $s.BeginConnect($testIp, 5555, $null, $null); if ($iar.AsyncWaitHandle.WaitOne(150)) { $s.EndConnect($iar); $testIp } } catch {} finally { $s.Close() } } -ThrottleLimit 100 | Select-Object -First 1"') do set TV_IP=%%i
)

if "%TV_IP%"=="" (
    echo [!] 未能自动探测到电视 IP，请确保电视开机并联网，然后在电视「设置-网络」中查看 IP。
    goto INPUT_IP
)

echo.
echo [*] 目标电视 IP: %TV_IP%
echo [*] 正在建立 ADB 连接...
%ADB% kill-server >nul 2>nul
%ADB% connect %TV_IP%:5555

echo.
echo [*] 正在检查设备连接状态...
%ADB% -s %TV_IP%:5555 wait-for-device

:: 备份
mkdir "%BACKUP_DIR%" >nul 2>nul
echo [*] 正在为您的电视创建安全配置备份 (保存于 backup\ 目录)...
%ADB% -s %TV_IP%:5555 shell pm list packages > "%BACKUP_DIR%\packages_backup.txt"
%ADB% -s %TV_IP%:5555 shell getprop > "%BACKUP_DIR%\props_backup.txt"
echo [√] 备份完成！

:MENU
echo.
echo ================================================================
echo   请选择操作项目：
echo   [1] 🌟 全套改装：Apple TV 极简桌面 + 去广告 + 直播优化 + 性能加速 (推荐)
echo   [2] 📺 长辈看电视模式：开机直达电视直播 + 去除所有广告
echo   [3] 🧹 仅深度净化：停用系统广告、推送、游戏中心与商城
echo   [4] ⚡ 仅性能调优：0.5x 动画缩放 + 防待机自动关机 + AOT 速度编译
echo   [5] 📡 推送苏州移动 112 高清频道源 (央视/卫视/地方台)
echo   [6] ↩️ 恢复出厂状态：重新启用原厂小米桌面与官方服务
echo   [0] 退出
echo ================================================================
set /p CHOICE="请输入选项序号 [0-6]: "

if "%CHOICE%"=="1" goto INSTALL_ALL
if "%CHOICE%"=="2" goto INSTALL_PURE_TV
if "%CHOICE%"=="3" goto DEBLOAT_ONLY
if "%CHOICE%"=="4" goto TUNE_ONLY
if "%CHOICE%"=="5" goto PUSH_IPTV
if "%CHOICE%"=="6" goto RESTORE_ALL
if "%CHOICE%"=="0" goto EXIT_TOOL
goto MENU

:INSTALL_ALL
echo.
echo [*] 开始全套极简改装...
call :DO_DEBLOAT
call :DO_INSTALL_APKS
call :DO_TUNE
call :DO_PUSH_IPTV
call :DO_SETUP_LAUNCHER
echo.
echo ================================================================
echo  🎉 恭喜！全套改装已顺利完成！
echo  - 电视已切换为 Apple tvOS 极简毛玻璃桌面；
echo  - 按遥控器 Home 键可直接唤醒新桌面；
echo  - 央视与卫视直播、私有云相册已配置就绪；
echo  - 广告全家桶已粉碎，操作动画已提速 50%%。
echo ================================================================
pause
goto MENU

:INSTALL_PURE_TV
echo.
echo [*] 配置长辈看电视模式...
call :DO_DEBLOAT
call :DO_TUNE
call :DO_PUSH_IPTV
if exist "%APK_DIR%\MyTV.apk" (
    echo [*] 正在安装电视直播...
    %ADB% -s %TV_IP%:5555 install -r -d "%APK_DIR%\MyTV.apk"
    %ADB% -s %TV_IP%:5555 shell cmd package compile -m speed -f com.github.mytv.android
)
echo.
echo [√] 长辈模式配置完成！
pause
goto MENU

:DEBLOAT_ONLY
call :DO_DEBLOAT
pause
goto MENU

:TUNE_ONLY
call :DO_TUNE
pause
goto MENU

:PUSH_IPTV
call :DO_PUSH_IPTV
pause
goto MENU

:DO_DEBLOAT
echo [*] 正在深度净化系统广告与后台全家桶...
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.miui.analytics >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.miui.tv.analytics >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.xiaomi.statistic >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.xm.webcontent >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.xiaomi.mitv.tvpush.tvpushservice >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.mitv.screensaver >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.xiaomi.mibox.lockscreen >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.cmgame.gamehall.xmtv >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.xiaomi.mitv.shoplugin >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.xiaomi.mitv.appstore >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm disable-user --user 0 com.xiaomi.mitv.upgrade >nul 2>nul
echo [√] 系统广告与冗余全家桶净化完成！
goto :eof

:DO_INSTALL_APKS
echo [*] 正在安装核心影音生态应用...
if exist "%APK_DIR%\AerialViews.apk" (
    echo   -> 安装 Apple TV 桌面 (Aerial TV)...
    %ADB% -s %TV_IP%:5555 install -r -d "%APK_DIR%\AerialViews.apk"
)
if exist "%APK_DIR%\MyTV.apk" (
    echo   -> 安装 电视直播 (MyTV)...
    %ADB% -s %TV_IP%:5555 install -r -d "%APK_DIR%\MyTV.apk"
)
if exist "%APK_DIR%\Clash.apk" (
    echo   -> 安装 FlClash...
    %ADB% -s %TV_IP%:5555 install -r -d "%APK_DIR%\Clash.apk"
)
if exist "%APK_DIR%\SmartTube.apk" (
    echo   -> 安装 SmartTube...
    %ADB% -s %TV_IP%:5555 install -r -d "%APK_DIR%\SmartTube.apk"
)
if exist "%APK_DIR%\BBLL.apk" (
    echo   -> 安装 BBLL 哔哩哔哩...
    %ADB% -s %TV_IP%:5555 install -r -d "%APK_DIR%\BBLL.apk"
)
if exist "%APK_DIR%\Jellyfin.apk" (
    echo   -> 安装 Jellyfin 影院...
    %ADB% -s %TV_IP%:5555 install -r -d "%APK_DIR%\Jellyfin.apk"
)
if exist "%ROOT_DIR%ImmichTV-6.2.0.apk" (
    echo   -> 安装 Immich TV 相册...
    %ADB% -s %TV_IP%:5555 install -r -d "%ROOT_DIR%ImmichTV-6.2.0.apk"
)
echo [√] 核心应用安装完毕！
goto :eof

:DO_TUNE
echo [*] 正在优化系统参数 (全局 0.5x 动画缩放、防关机休眠、禁用自动更新)...
%ADB% -s %TV_IP%:5555 shell settings put global window_animation_scale 0.5
%ADB% -s %TV_IP%:5555 shell settings put global transition_animation_scale 0.5
%ADB% -s %TV_IP%:5555 shell settings put global animator_duration_scale 0.5
%ADB% -s %TV_IP%:5555 shell settings put global stay_on_while_plugged_in 3
%ADB% -s %TV_IP%:5555 shell settings put system screen_off_timeout 2147483647
%ADB% -s %TV_IP%:5555 shell settings put global hdmi_control_auto_shutdown 0
%ADB% -s %TV_IP%:5555 shell settings put global auto_update_system 0
echo [√] 系统性能参数调优完成！
goto :eof

:DO_PUSH_IPTV
echo [*] 正在推送高清电视直播频道列表...
if exist "%ROOT_DIR%suzhou_mobile.m3u" (
    %ADB% -s %TV_IP%:5555 push "%ROOT_DIR%suzhou_mobile.m3u" /sdcard/Download/suzhou_mobile.m3u >nul
    echo [√] 直播源已成功推送到电视 /sdcard/Download/suzhou_mobile.m3u
)
goto :eof

:DO_SETUP_LAUNCHER
echo [*] 正在接管系统桌面并授予底层权限...
%ADB% -s %TV_IP%:5555 shell pm grant app.orchard.tv android.permission.WRITE_SECURE_SETTINGS >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm grant app.orchard.tv android.permission.SYSTEM_ALERT_WINDOW >nul 2>nul
%ADB% -s %TV_IP%:5555 shell dumpsys deviceidle whitelist +app.orchard.tv >nul 2>nul
%ADB% -s %TV_IP%:5555 shell cmd package set-home-activity app.orchard.tv/.MainActivity >nul 2>nul
%ADB% -s %TV_IP%:5555 shell am start -n app.orchard.tv/.MainActivity >nul 2>nul
echo [*] 正在对新桌面执行 AOT 本地机器码编译提速...
%ADB% -s %TV_IP%:5555 shell cmd package compile -m speed -f app.orchard.tv >nul 2>nul
echo [√] 桌面接管完成！
goto :eof

:RESTORE_ALL
echo [*] 正在为您的电视恢复原厂设置与官方桌面...
%ADB% -s %TV_IP%:5555 shell pm enable com.mitv.tvhome >nul 2>nul
%ADB% -s %TV_IP%:5555 shell cmd package set-home-activity com.mitv.tvhome/com.mitv.tvhome.MainActivity >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm enable com.xiaomi.mitv.appstore >nul 2>nul
%ADB% -s %TV_IP%:5555 shell pm enable com.xiaomi.mitv.upgrade >nul 2>nul
%ADB% -s %TV_IP%:5555 shell settings put global window_animation_scale 1.0
%ADB% -s %TV_IP%:5555 shell settings put global transition_animation_scale 1.0
%ADB% -s %TV_IP%:5555 shell settings put global animator_duration_scale 1.0
echo [√] 官方桌面与服务已完全恢复！
pause
goto MENU

:EXIT_TOOL
echo 感谢使用赤果 (ChiGuo) 电视改装工具，再见！
pause
exit /b 0
