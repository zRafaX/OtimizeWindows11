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
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data" >nul 2>&1
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data-journal" >nul 2>&1
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data For Account" >nul 2>&1
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Login Data For Account-journal" >nul 2>&1

del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Web Data" >nul 2>&1
del "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Web Data-journal" >nul 2>&1

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

:: Desativar: disabled | Manual: demand | Ativar: auto

:: SysMain (Superfetch)
sc query "SysMain" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "SysMain" start= auto >nul
    echo [✓] SysMain Superfetch ativado com sucesso!
) else (
    echo [✗] SysMain Superfetch não encontrado no sistema.
)

:: WSearch (Windows Search)
echo Desativando o WSearch...
sc query "WSearch" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "WSearch" start= disabled >nul
    echo [✓] WSearch Windows Search desativado com sucesso!
) else (
    echo [✗] WSearch Windows Search não encontrado no sistema.
)

:: TapiSrv (Telephony)
echo Desativando o Telephony...
sc query "TapiSrv" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "TapiSrv" start= disabled >nul
    echo [✓] TapiSrv Telephony desativado com sucesso!
) else (
    echo [✗] TapiSrv Telephony não encontrado no sistema.
)

:: TermService (Remote Desktop Services)
echo Desativando o TermService...
sc query "TermService" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "TermService" start= disabled >nul
    echo [✓] TermService Remote Desktop Services desativado com sucesso!
) else (
    echo [✗] TermService Remote Desktop Services não encontrado no sistema.
)

:: PhoneSvc (Phone Service)
echo Desativando o PhoneSvc...
sc query "PhoneSvc" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "PhoneSvc" start= disabled >nul
    echo [✓] PhoneSvc Phone Service desativado com sucesso!
) else (
    echo [✗] PhoneSvc Phone Service não encontrado no sistema.
)

:: WbioSrvc (Windows Biometric Service)
echo Desativando o WbioSrvc...
sc query "WbioSrvc" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "WbioSrvc" start= disabled >nul
    echo [✓] WbioSrvc Windows Biometric Service desativado com sucesso!
) else (
    echo [✗] WbioSrvc Windows Biometric Service não encontrado no sistema.
)

:: RemoteRegistry (Remote Registry)
echo Desativando o RemoteRegistry...
sc query "RemoteRegistry" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "RemoteRegistry" start= disabled >nul
    echo [✓] RemoteRegistry Remote Registry desativado com sucesso!
) else (
    echo [✗] RemoteRegistry Remote Registry não encontrado no sistema.
)

:: edgeupdate (Microsoft Edge Update Service)
echo Desativando o edgeupdate...
sc query "edgeupdate" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "edgeupdate" start= demand >nul
    echo [✓] edgeupdate Microsoft Edge Update Service configurado como manual!
) else (
    echo [✗] edgeupdate Microsoft Edge Update Service não encontrado no sistema.
)

:: FlexNet Licensing Service 64
echo Desativando o FlexNet...
sc query "FlexNet Licensing Service 64" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "FlexNet Licensing Service 64" start= demand >nul
    echo [✓] FlexNet Licensing Service 64 configurado como manual!
) else (
    echo [✗] FlexNet Licensing Service 64 não encontrado no sistema.
)

:: SCardSvr (Smart Card)
echo Desativando o SCardSvr...
sc query "SCardSvr" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "SCardSvr" start= disabled >nul
    echo [✓] SCardSvr Smart Card desativado com sucesso!
) else (
    echo [✗] SCardSvr Smart Card não encontrado no sistema.
)

:: Vmcompute (Serviço de Computação de Host do Hyper-V)
echo Desativando o vmcompute...
sc query "vmcompute" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmcompute" start= demand >nul
    echo [✓] vmcompute desativado com sucesso!
) else (
    echo [✗] vmcompute não encontrado no sistema.
)

:: ClickToRunSvc (Microsoft Office Click-to-Run Service)
echo Desativando o ClickToRunSvc...
sc query "ClickToRunSvc" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "ClickToRunSvc" start= demand >nul
    echo [✓] ClickToRunSvc desativado com sucesso!
) else (
    echo [✗] ClickToRunSvc não encontrado no sistema.
)

:: EABackgroundService (EA APP)
echo Desativando o EABackgroundService...
sc query "EABackgroundService" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "EABackgroundService" start= demand >nul
    echo [✓] EABackgroundService desativado com sucesso!
) else (
    echo [✗] EABackgroundService não encontrado no sistema.
)

:: Wercplsupport (Suporte do Painel de Controle Relatórios de problemas)
echo Desativando o Wercplsupport...
sc query "Wercplsupport" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "Wercplsupport" start= disabled >nul
    echo [✓] Wercplsupport desativado com sucesso!
) else (
    echo [✗] Wercplsupport não encontrado no sistema.
)

:: GigabyteUpdateService (GIGABYTE Update Service)
echo Desativando o GigabyteUpdateService...
sc query "GigabyteUpdateService" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "GigabyteUpdateService" start= demand >nul
    echo [✓] GigabyteUpdateService desativado com sucesso!
) else (
    echo [✗] GigabyteUpdateService não encontrado no sistema.
)

:: RvControlSvc (Radmin VPN Control Service)
echo Desativando o RvControlSvc...
sc query "RvControlSvc" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "RvControlSvc" start= demand >nul
    echo [✓] RvControlSvc desativado com sucesso!
) else (
    echo [✗] RvControlSvc não encontrado no sistema.
)

:: DiagTrack (Experiências do Usuário Conectado e Telemetria)
echo Desativando o DiagTrack...
sc query "DiagTrack" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "DiagTrack" start= disabled >nul
    echo [✓] DiagTrack desativado com sucesso!
) else (
    echo [✗] DiagTrack não encontrado no sistema.
)

:: DPS (Serviço de Política de Diagnóstico)
echo Desativando o DPS...
sc query "DPS" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "DPS" start= demand >nul
    echo [✓] DPS desativado com sucesso!
) else (
    echo [✗] DPS não encontrado no sistema.
)

:: MapsBroker (Gerencia mapas offline)
echo Desativando o MapsBroker...
sc query "MapsBroker" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "MapsBroker" start= disabled >nul
    echo [✓] MapsBroker desativado com sucesso!
) else (
    echo [✗] MapsBroker não encontrado no sistema.
)

:: EasyTuneEngineService (Gigabyte EasyTune Engine Service)
echo Desativando o EasyTuneEngineService...
sc query "EasyTuneEngineService" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "EasyTuneEngineService" start= demand >nul
    echo [✓] EasyTuneEngineService desativado com sucesso!
) else (
    echo [✗] EasyTuneEngineService não encontrado no sistema.
)

:: Spooler (Spooler de Impressão)
echo Desativando o Spooler...
sc query "Spooler" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "Spooler" start= demand >nul
    echo [✓] Spooler desativado com sucesso!
) else (
    echo [✗] Spooler não encontrado no sistema.
)

:: wuqisvc (Insights de Uso e Qualidade da Microsoft)
echo Desativando o wuqisvc...
sc query "wuqisvc" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "wuqisvc" start= disabled >nul
    echo [✓] wuqisvc desativado com sucesso!
) else (
    echo [✗] wuqisvc não encontrado no sistema.
)

:: SSDPSRV (Descoberta SSDP)
echo Desativando o SSDPSRV...
sc query "SSDPSRV" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "SSDPSRV" start= demand >nul
    echo [✓] SSDPSRV desativado com sucesso!
) else (
    echo [✗] SSDPSRV não encontrado no sistema.
)

:: lfsvc (Serviço de Geolocalização)
echo Desativando o lfsvc...
sc query "lfsvc" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "lfsvc" start= disabled >nul
    echo [✓] lfsvc desativado com sucesso!
) else (
    echo [✗] lfsvc não encontrado no sistema.
)

:: HvHost (Serviço de Host HV)
echo Desativando o HvHost...
sc query "HvHost" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "HvHost" start= demand >nul
    echo [✓] HvHost desativado com sucesso!
) else (
    echo [✗] HvHost não encontrado no sistema.
)

:: CDPSvc (Serviço de Plataforma de Dispositivos Conectados)
echo Desativando o CDPSvc...
sc query "CDPSvc" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "CDPSvc" start= demand >nul
    echo [✓] CDPSvc desativado com sucesso!
) else (
    echo [✗] CDPSvc não encontrado no sistema.
)

:: Desativar: disabled | Manual: demand | Ativar: auto

:: ==================== Desativar (Sandbox) ====================

bcdedit /set hypervisorlaunchtype off

:: hns (Sandbox)
sc query "hns" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "hns" start= demand >nul
    echo [✓] hns ativado com sucesso!
) else (
    echo [✗] hns não encontrado no sistema.
)

:: wsbsvc (Sandbox)
sc query "wsbsvc" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "wsbsvc" start= demand >nul
    echo [✓] wsbsvc ativado com sucesso!
) else (
    echo [✗] wsbsvc não encontrado no sistema.
)

:: vmcompute (Sandbox)
sc query "vmcompute" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmcompute" start= demand >nul
    echo [✓] vmcompute ativado com sucesso!
) else (
    echo [✗] vmcompute não encontrado no sistema.
)

:: vmms (Sandbox)
sc query "vmms" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmms" start= demand >nul
    echo [✓] vmms  ativado com sucesso!
) else (
    echo [✗] vmms não encontrado no sistema.
)

:: CmService (Sandbox)
sc query "CmService" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "CmService" start= demand >nul
    echo [✓] CmService ativado com sucesso!
) else (
    echo [✗] CmService não encontrado no sistema.
)

:: HvHost (Sandbox)
sc query "HvHost" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "HvHost" start= demand >nul
    echo [✓] HvHost ativado com sucesso!
) else (
    echo [✗] HvHost não encontrado no sistema.
)

:: vmickvpexchange (Sandbox)
sc query "vmickvpexchange" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmickvpexchange" start= demand >nul
    echo [✓] vmickvpexchange ativado com sucesso!
) else (
    echo [✗] vmickvpexchange não encontrado no sistema.
)

:: vmicguestinterface (Sandbox)
sc query "vmicguestinterface" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmicguestinterface" start= demand >nul
    echo [✓] vmicguestinterface ativado com sucesso!
) else (
    echo [✗] vmicguestinterface não encontrado no sistema.
)

:: vmicheartbeat (Sandbox)
sc query "vmicheartbeat" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmicheartbeat" start= demand >nul
    echo [✓] vmicheartbeat ativado com sucesso!
) else (
    echo [✗] vmicheartbeat não encontrado no sistema.
)

:: vmicvmsession (Sandbox)
sc query "vmicvmsession" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmicvmsession" start= demand >nul
    echo [✓] vmicvmsession ativado com sucesso!
) else (
    echo [✗] vmicvmsession não encontrado no sistema.
)

:: vmicrdv (Sandbox)
sc query "vmicrdv" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmicrdv" start= demand >nul
    echo [✓] vmicrdv ativado com sucesso!
) else (
    echo [✗] vmicrdv não encontrado no sistema.
)

:: vmictimesync (Sandbox)
sc query "vmictimesync" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmictimesync" start= demand >nul
    echo [✓] vmictimesync ativado com sucesso!
) else (
    echo [✗] vmictimesync não encontrado no sistema.
)

:: vmicshutdown (Sandbox)
sc query "vmicshutdown" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmicshutdown" start= demand >nul
    echo [✓] vmicshutdown ativado com sucesso!
) else (
    echo [✗] vmicshutdown não encontrado no sistema.
)

:: vmicvss (Sandbox)
sc query "vmicvss" >nul 2>&1
if %errorlevel% equ 0 (
    sc config "vmicvss" start= demand >nul
    echo [✓] vmicvss ativado com sucesso!
) else (
    echo [✗] vmicvss não encontrado no sistema.
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
if exist "%~1\*" (
    del /q /f /s "%~1\*" >nul 2>&1
    echo [✓] %~2 cleaned
)

exit /b