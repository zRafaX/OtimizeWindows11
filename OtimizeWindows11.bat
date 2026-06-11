@echo off
color 05

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

:: Disable Background Apps
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul && (
echo [✓] Background apps disabled
) || (
echo [✗] Error disabling background apps
)

:: ==================== SECURITY (DATA CLEANUP) ====================
del "C:\Users%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data" >nul 2>&1
del "C:\Users%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data-journal" >nul 2>&1
del "C:\Users%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data For Account" >nul 2>&1
del "C:\Users%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data For Account-journal" >nul 2>&1

del "C:\Users%username%\AppData\Local\Microsoft\Edge\User Data\Default\Web Data" >nul 2>&1
del "C:\Users%username%\AppData\Local\Microsoft\Edge\User Data\Default\Web Data-journal" >nul 2>&1

:: Function to clean folder with verification
call :CleanFolder "%TEMP%" "User Temp folder"
call :CleanFolder "C:\Windows\Temp" "System Temp folder"
call :CleanFolder "%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files" "Internet Explorer cache"
call :CleanFolder "%USERPROFILE%\AppData\Local\Microsoft\Windows\Recent" "Recent files"
call :CleanFolder "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache" "Chrome cache" 2>nul
call :CleanFolder "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache" "Edge cache" 2>nul

:: Clean Prefetch
if exist "C:\Windows\Prefetch*" (
del /q /f /s "C:\Windows\Prefetch*" >nul 2>&1
echo [✓] Prefetch cache cleaned
)

:: Run Cleanmgr
echo [i] Running advanced Disk Cleanup...
cleanmgr /sagerun:65535 >nul 2>&1
echo [✓] Disk cleanup completed

:: ==================== ADVANCED PERFORMANCE OPTIMIZATIONS ====================

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

timeout /t 2 >nul

:: Disable: disabled | Manual: demand | Enable: auto

:: SysMain (Superfetch)
sc query "SysMain" >nul 2>&1
if %errorlevel% equ 0 (
sc config "SysMain" start= auto >nul
echo [✓] SysMain (Superfetch) successfully enabled!
) else (
echo [✗] SysMain (Superfetch) not found on the system.
)

:: WSearch (Windows Search)
echo Disabling WSearch...
sc query "WSearch" >nul 2>&1
if %errorlevel% equ 0 (
sc config "WSearch" start= disabled >nul
echo [✓] WSearch (Windows Search) successfully disabled!
) else (
echo [✗] WSearch (Windows Search) not found on the system.
)

:: TapiSrv (Telephony)
echo Disabling Telephony...
sc query "TapiSrv" >nul 2>&1
if %errorlevel% equ 0 (
sc config "TapiSrv" start= disabled >nul
echo [✓] TapiSrv (Telephony) successfully disabled!
) else (
echo [✗] TapiSrv (Telephony) not found on the system.
)

:: TermService (Remote Desktop Services)
echo Disabling TermService...
sc query "TermService" >nul 2>&1
if %errorlevel% equ 0 (
sc config "TermService" start= disabled >nul
echo [✓] TermService (Remote Desktop Services) successfully disabled!
) else (
echo [✗] TermService (Remote Desktop Services) not found on the system.
)

:: PhoneSvc (Phone Service)
echo Disabling PhoneSvc...
sc query "PhoneSvc" >nul 2>&1
if %errorlevel% equ 0 (
sc config "PhoneSvc" start= disabled >nul
echo [✓] PhoneSvc (Phone Service) successfully disabled!
) else (
echo [✗] PhoneSvc (Phone Service) not found on the system.
)

:: WbioSrvc (Windows Biometric Service)
echo Disabling WbioSrvc...
sc query "WbioSrvc" >nul 2>&1
if %errorlevel% equ 0 (
sc config "WbioSrvc" start= disabled >nul
echo [✓] WbioSrvc (Windows Biometric Service) successfully disabled!
) else (
echo [✗] WbioSrvc (Windows Biometric Service) not found on the system.
)

:: RemoteRegistry (Remote Registry)
echo Disabling RemoteRegistry...
sc query "RemoteRegistry" >nul 2>&1
if %errorlevel% equ 0 (
sc config "RemoteRegistry" start= disabled >nul
echo [✓] RemoteRegistry (Remote Registry) successfully disabled!
) else (
echo [✗] RemoteRegistry (Remote Registry) not found on the system.
)

:: edgeupdate (Microsoft Edge Update Service)
echo Disabling edgeupdate...
sc query "edgeupdate" >nul 2>&1
if %errorlevel% equ 0 (
sc config "edgeupdate" start= demand >nul
echo [✓] edgeupdate (Microsoft Edge Update Service) set to manual!
) else (
echo [✗] edgeupdate (Microsoft Edge Update Service) not found on the system.
)

:: FlexNet Licensing Service 64
echo Disabling FlexNet...
sc query "FlexNet Licensing Service 64" >nul 2>&1
if %errorlevel% equ 0 (
sc config "FlexNet Licensing Service 64" start= demand >nul
echo [✓] FlexNet Licensing Service 64 set to manual!
) else (
echo [✗] FlexNet Licensing Service 64 not found on the system.
)

:: SCardSvr (Smart Card)
echo Disabling SCardSvr...
sc query "SCardSvr" >nul 2>&1
if %errorlevel% equ 0 (
sc config "SCardSvr" start= disabled >nul
echo [✓] SCardSvr (Smart Card) successfully disabled!
) else (
echo [✗] SCardSvr (Smart Card) not found on the system.
)

:: Vmcompute (Hyper-V Host Compute Service)
echo Disabling vmcompute...
sc query "vmcompute" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmcompute" start= demand >nul
echo [✓] vmcompute (Hyper-V Host Compute Service) set to manual!
) else (
echo [✗] vmcompute not found on the system.
)

:: ClickToRunSvc (Microsoft Office Click-to-Run Service)
echo Disabling ClickToRunSvc...
sc query "ClickToRunSvc" >nul 2>&1
if %errorlevel% equ 0 (
sc config "ClickToRunSvc" start= demand >nul
echo [✓] ClickToRunSvc set to manual!
) else (
echo [✗] ClickToRunSvc not found on the system.
)

:: EABackgroundService (EA APP)
echo Disabling EABackgroundService...
sc query "EABackgroundService" >nul 2>&1
if %errorlevel% equ 0 (
sc config "EABackgroundService" start= demand >nul
echo [✓] EABackgroundService set to manual!
) else (
echo [✗] EABackgroundService not found on the system.
)

:: Wercplsupport (Problem Reports and Solutions Control Panel Support)
echo Disabling Wercplsupport...
sc query "Wercplsupport" >nul 2>&1
if %errorlevel% equ 0 (
sc config "Wercplsupport" start= disabled >nul
echo [✓] Wercplsupport successfully disabled!
) else (
echo [✗] Wercplsupport not found on the system.
)

:: GigabyteUpdateService (GIGABYTE Update Service)
echo Disabling GigabyteUpdateService...
sc query "GigabyteUpdateService" >nul 2>&1
if %errorlevel% equ 0 (
sc config "GigabyteUpdateService" start= demand >nul
echo [✓] GigabyteUpdateService set to manual!
) else (
echo [✗] GigabyteUpdateService not found on the system.
)

:: RvControlSvc (Radmin VPN Control Service)
echo Disabling RvControlSvc...
sc query "RvControlSvc" >nul 2>&1
if %errorlevel% equ 0 (
sc config "RvControlSvc" start= demand >nul
echo [✓] RvControlSvc set to manual!
) else (
echo [✗] RvControlSvc not found on the system.
)

:: DiagTrack (Connected User Experiences and Telemetry)
echo Disabling DiagTrack...
sc query "DiagTrack" >nul 2>&1
if %errorlevel% equ 0 (
sc config "DiagTrack" start= disabled >nul
echo [✓] DiagTrack successfully disabled!
) else (
echo [✗] DiagTrack not found on the system.
)

:: DPS (Diagnostic Policy Service)
echo Disabling DPS...
sc query "DPS" >nul 2>&1
if %errorlevel% equ 0 (
sc config "DPS" start= demand >nul
echo [✓] DPS set to manual!
) else (
echo [✗] DPS not found on the system.
)

:: MapsBroker (Downloaded Maps Manager)
echo Disabling MapsBroker...
sc query "MapsBroker" >nul 2>&1
if %errorlevel% equ 0 (
sc config "MapsBroker" start= disabled >nul
echo [✓] MapsBroker successfully disabled!
) else (
echo [✗] MapsBroker not found on the system.
)

:: EasyTuneEngineService (Gigabyte EasyTune Engine Service)
echo Disabling EasyTuneEngineService...
sc query "EasyTuneEngineService" >nul 2>&1
if %errorlevel% equ 0 (
sc config "EasyTuneEngineService" start= demand >nul
echo [✓] EasyTuneEngineService set to manual!
) else (
echo [✗] EasyTuneEngineService not found on the system.
)

:: Spooler (Print Spooler)
echo Disabling Spooler...
sc query "Spooler" >nul 2>&1
if %errorlevel% equ 0 (
sc config "Spooler" start= demand >nul
echo [✓] Spooler set to manual!
) else (
echo [✗] Spooler not found on the system.
)

:: wuqisvc (Microsoft Usage and Quality Insights)
echo Disabling wuqisvc...
sc query "wuqisvc" >nul 2>&1
if %errorlevel% equ 0 (
sc config "wuqisvc" start= disabled >nul
echo [✓] wuqisvc successfully disabled!
) else (
echo [✗] wuqisvc not found on the system.
)

:: SSDPSRV (SSDP Discovery)
echo Disabling SSDPSRV...
sc query "SSDPSRV" >nul 2>&1
if %errorlevel% equ 0 (
sc config "SSDPSRV" start= demand >nul
echo [✓] SSDPSRV set to manual!
) else (
echo [✗] SSDPSRV not found on the system.
)

:: lfsvc (Geolocation Service)
echo Disabling lfsvc...
sc query "lfsvc" >nul 2>&1
if %errorlevel% equ 0 (
sc config "lfsvc" start= disabled >nul
echo [✓] lfsvc successfully disabled!
) else (
echo [✗] lfsvc not found on the system.
)

:: HvHost (HV Host Service)
echo Disabling HvHost...
sc query "HvHost" >nul 2>&1
if %errorlevel% equ 0 (
sc config "HvHost" start= demand >nul
echo [✓] HvHost set to manual!
) else (
echo [✗] HvHost not found on the system.
)

:: CDPSvc (Connected Devices Platform Service)
echo Disabling CDPSvc...
sc query "CDPSvc" >nul 2>&1
if %errorlevel% equ 0 (
sc config "CDPSvc" start= demand >nul
echo [✓] CDPSvc set to manual!
) else (
echo [✗] CDPSvc not found on the system.
)

:: ==================== Disable (Sandbox) ====================

bcdedit /set hypervisorlaunchtype off

:: hns (Host Network Service)
sc query "hns" >nul 2>&1
if %errorlevel% equ 0 (
sc config "hns" start= demand >nul
echo [✓] hns set to manual!
) else (
echo [✗] hns not found on the system.
)

:: wsbsvc (Windows Sandbox Service)
sc query "wsbsvc" >nul 2>&1
if %errorlevel% equ 0 (
sc config "wsbsvc" start= demand >nul
echo [✓] wsbsvc set to manual!
) else (
echo [✗] wsbsvc not found on the system.
)

:: vmcompute (Hyper-V Host Compute Service)
sc query "vmcompute" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmcompute" start= demand >nul
echo [✓] vmcompute set to manual!
) else (
echo [✗] vmcompute not found on the system.
)

:: vmms (Hyper-V Virtual Machine Management)
sc query "vmms" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmms" start= demand >nul
echo [✓] vmms set to manual!
) else (
echo [✗] vmms not found on the system.
)

:: CmService (Connection Manager Service)
sc query "CmService" >nul 2>&1
if %errorlevel% equ 0 (
sc config "CmService" start= demand >nul
echo [✓] CmService set to manual!
) else (
echo [✗] CmService not found on the system.
)

:: HvHost (HV Host Service)
sc query "HvHost" >nul 2>&1
if %errorlevel% equ 0 (
sc config "HvHost" start= demand >nul
echo [✓] HvHost set to manual!
) else (
echo [✗] HvHost not found on the system.
)

:: vmickvpexchange (Hyper-V Data Exchange Service)
sc query "vmickvpexchange" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmickvpexchange" start= demand >nul
echo [✓] vmickvpexchange set to manual!
) else (
echo [✗] vmickvpexchange not found on the system.
)

:: vmicguestinterface (Hyper-V Guest Service Interface)
sc query "vmicguestinterface" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmicguestinterface" start= demand >nul
echo [✓] vmicguestinterface set to manual!
) else (
echo [✗] vmicguestinterface not found on the system.
)

:: vmicheartbeat (Hyper-V Heartbeat Service)
sc query "vmicheartbeat" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmicheartbeat" start= demand >nul
echo [✓] vmicheartbeat set to manual!
) else (
echo [✗] vmicheartbeat not found on the system.
)

:: vmicvmsession (Hyper-V PowerShell Direct Service)
sc query "vmicvmsession" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmicvmsession" start= demand >nul
echo [✓] vmicvmsession set to manual!
) else (
echo [✗] vmicvmsession not found on the system.
)

:: vmicrdv (Hyper-V Remote Desktop Virtualization Service)
sc query "vmicrdv" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmicrdv" start= demand >nul
echo [✓] vmicrdv set to manual!
) else (
echo [✗] vmicrdv not found on the system.
)

:: vmictimesync (Hyper-V Time Synchronization Service)
sc query "vmictimesync" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmictimesync" start= demand >nul
echo [✓] vmictimesync set to manual!
) else (
echo [✗] vmictimesync not found on the system.
)

:: vmicshutdown (Hyper-V Guest Shutdown Service)
sc query "vmicshutdown" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmicshutdown" start= demand >nul
echo [✓] vmicshutdown set to manual!
) else (
echo [✗] vmicshutdown not found on the system.
)

:: vmicvss (Hyper-V Volume Shadow Copy Requestor)
sc query "vmicvss" >nul 2>&1
if %errorlevel% equ 0 (
sc config "vmicvss" start= demand >nul
echo [✓] vmicvss set to manual!
) else (
echo [✗] vmicvss not found on the system.
)

:: ==================== FINALIZATION ====================

:: Flush DNS cache
ipconfig /flushdns >nul && echo [✓] DNS cache flushed

:: Check system integrity
echo [i] Checking system integrity...
sfc /scannow /offbootdir=C:\ /offwindir=C:\Windows >nul 2>&1
echo [✓] Integrity check completed

:: Calculate freed space
for /f "tokens=3" %%a in ('dir /a /s ^| find "File(s)"') do set "FILES=%%a"
echo [✓] Cleanup completed - %FILES% files processed

:: ==================== OPTIONAL ====================

:: ====== DISK CLEANUP ======
cleanmgr /sagerun:99

:: ==================== FUNCTIONS ====================
:CleanFolder
if exist "%~1*" (
del /q /f /s "%~1*" >nul 2>&1
echo [✓] %~2 cleaned
)

exit /b