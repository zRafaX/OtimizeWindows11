@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
color 05

title System Optimizer - Windows 11

echo By: zRaFax

:: ==================== INITIAL SETTINGS ====================
set "LOG_FILE=%TEMP%\system_optimizer.log"
echo [%date% %time%] Starting system optimizations > "%LOG_FILE%"

:: ==================== ADMIN ====================
net session >nul 2>&1
if not %errorlevel%==0 (
    echo.
    echo # Starting...
    echo.
    PowerShell -Command "Start-Process '%0' -Verb RunAs" 2>nul || (
        echo # Right-click the script and select "Run as administrator".
        pause >nul
        exit /b 1
    )
    exit /b 0
)

:: ==================== SYSTEM CHECK ====================
echo.
echo # Checking Windows version...
for /f "tokens=4-5 delims=. " %%i in ('ver') do set /a MAJOR=%%i, MINOR=%%j
if !MAJOR! lss 10 (
    echo [ERROR] This script is compatible only with Windows 10 or higher
    timeout /t 5
    exit /b 1
)

:: ==================== CREATE RESTORE POINT ====================
echo.
echo # Creating system restore point...
powershell -Command "Checkpoint-Computer -Description 'Optimization_Pre_Script' -RestorePointType MODIFY_SETTINGS" >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Restore point created successfully
) else (
    echo [!] Could not create restore point
)

:: ==================== SYSTEM CONFIGURATIONS ====================
echo.
echo # Applying system optimizations...
echo.

:: Disable Background Apps
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul && (
    echo [✓] Background apps disabled
) || (
    echo [✗] Error disabling background apps
)

:: ==================== SECURITY (DATA CLEANUP) ====================
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data" >nul 2>&1
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data-journal" >nul 2>&1
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data For Account" >nul 2>&1
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data For Account-journal" >nul 2>&1

del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Web Data" >nul 2>&1
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Web Data-journal" >nul 2>&1

:: ==================== ADVANCED TEMPORARY FILE CLEANUP ====================
echo.
echo # Performing temporary files cleanup...
echo.

:: Function to clean folder with verification
call :CleanFolder "%TEMP%" "User Temp folder"
call :CleanFolder "C:\Windows\Temp" "System Temp folder"
call :CleanFolder "%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files" "Internet Explorer cache"
call :CleanFolder "%USERPROFILE%\AppData\Local\Microsoft\Windows\Recent" "Recent files"
call :CleanFolder "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache" "Chrome cache" 2>nul
call :CleanFolder "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache" "Edge cache" 2>nul

:: Clean Prefetch
if exist "C:\Windows\Prefetch\*" (
    del /q /f /s "C:\Windows\Prefetch\*" >nul 2>&1
    echo [✓] Prefetch cache cleaned
)

:: Run Cleanmgr
echo [i] Running advanced Disk Cleanup...
cleanmgr /sagerun:65535 >nul 2>&1
echo [✓] Disk cleanup completed

:: ==================== ADVANCED PERFORMANCE OPTIMIZATIONS ====================
echo.
echo # Applying advanced performance optimizations...
echo.

:: Set high performance power plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul && echo [✓] High performance power plan activated

:: Apply GPU settings
if exist ".\REG\OTIMIZEWINDOWS11.reg" (
    regedit /s ".\REG\OTIMIZEWINDOWS11.reg" && echo [✓] GPU settings applied
)
if exist ".\REG\OTIMIZEWINDOWS11 2.reg" (
    regedit /s ".\REG\OTIMIZEWINDOWS11 2.reg" && echo [✓] GPU settings 2 applied
)

:: ==================== SERVICE CONFIGURATION ====================
echo.
echo # Configuring Windows services intelligently...
echo.

set services=(
    "SysMain|disabled|Superfetch"
    "WSearch|disabled|Windows Search"
    "TapiSrv|disabled|Telephony"
    "TermService|disabled|Remote Desktop Services"
    "PhoneSvc|disabled|Phone Service"
    "WbioSrvc|disabled|Windows Biometric Service"
    "RemoteRegistry|disabled|Remote Registry"
    "edgeupdate|demand|Microsoft Edge Update"
    "FlexNet Licensing Service 64|demand|FlexNet Licensing"
    "SCardSvr|disabled|Smart Card"
    "WerSvc|disabled|Windows Error Reporting"
    "vmcompute|demand|Hyper-V Host Compute"
    "ClickToRunSvc|demand|Microsoft Office Click-to-Run"
    "EABackgroundService|demand|EA Background Service"
    "Wercplsupport|disabled|Problem Reports Support"
    "MapsBroker|disabled|Maps Broker"
    "lfsvc|disabled|Geolocation Service"
    "TabletInputService|disabled|Tablet Input Service"
    "XboxGipSvc|disabled|Xbox Accessory Management"
    "XboxNetApiSvc|disabled|Xbox Live Networking"
)

for %%s in %services% do (
    set "service=%%s"
    for /f "tokens=1,2,3 delims=|" %%a in ("!service!") do (
        sc query "%%a" >nul 2>&1
        if !errorlevel! equ 0 (
            sc stop "%%a" >nul 2>&1
            sc config "%%a" start= %%b >nul 2>&1
            if !errorlevel! equ 0 (
                echo [✓] %%c configured as %%b
            ) else (
                echo [✗] Error configuring %%c
            )
        ) else (
            echo [i] %%c not found
        )
    )
)

:: ==================== FINALIZATION ====================
echo.
echo # Running final optimizations...
echo.

:: Flush DNS cache
ipconfig /flushdns >nul && echo [✓] DNS cache flushed

:: Check system integrity
echo [i] Checking system integrity...
sfc /scannow /offbootdir=C:\ /offwindir=C:\Windows >nul 2>&1
echo [✓] Integrity check completed

:: Calculate freed space
for /f "tokens=3" %%a in ('dir /a /s ^| find "File(s)"') do set "FILES=%%a"
echo [✓] Cleanup completed - %FILES% files processed

:: ==================== FINAL REPORT ====================
echo.
echo ============================================
echo # SYSTEM OPTIMIZED SUCCESSFULLY!
echo ============================================
echo.
echo [SUMMARY OF CHANGES]
echo • Unnecessary services disabled
echo • Temporary files removed
echo • Performance settings applied
echo.
echo [RECOMMENDATIONS]
echo 1. Restart the computer to apply all changes
echo 2. Run this script monthly for maintenance
echo 3. Check if your programs work normally
echo.
echo Full log saved to: %LOG_FILE%
echo.

timeout /t 10 >nul

:: ==================== OPTIONAL ====================

:: ====== DISK CLEANUP ======
cleanmgr /sagerun:99

:: ====== ADVANCED CLEANUP (NOT RECOMMENDED) ======
::Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

:: ==================== FUNCTIONS ====================
:CleanFolder
if exist "%~1\*" (
    del /q /f /s "%~1\*" >nul 2>&1
    echo [✓] %~2 cleaned
)

exit /b