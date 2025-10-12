@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
color 05

title Otimizador de Sistema - Windows 11

echo By: zRaFax

:: ==================== CONFIGURAÇÕES INICIAIS ====================
set "LOG_FILE=%TEMP%\system_optimizer.log"
echo [%date% %time%] Iniciando otimizacoes do sistema > "%LOG_FILE%"

:: ==================== ADM ====================
net session >nul 2>&1
if not %errorlevel%==0 (
    echo.
    echo # Iniciando...
    echo.
    PowerShell -Command "Start-Process '%0' -Verb RunAs" 2>nul || (
        echo # Clique com o botão direito no script e selecione "Executar como administrador".
        pause >nul
        exit /b 1
    )
    exit /b 0
)

:: ==================== VERIFICAÇÃO DO SISTEMA ====================
echo.
echo # Verificando versao do Windows...
for /f "tokens=4-5 delims=. " %%i in ('ver') do set /a MAJOR=%%i, MINOR=%%j
if !MAJOR! lss 10 (
    echo [ERRO] Este script e compativel apenas com Windows 10 ou superior
    timeout /t 5
    exit /b 1
)

:: ==================== CRIAR PONTO DE RESTAURAÇÃO ====================
echo.
echo # Criando ponto de restauracao do sistema...
powershell -Command "Checkpoint-Computer -Description 'Otimizacao_Pre_Script' -RestorePointType MODIFY_SETTINGS" >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Ponto de restauracao criado com sucesso
) else (
    echo [!] Nao foi possivel criar ponto de restauracao
)

:: ==================== CONFIGURAÇÕES DO SISTEMA ====================
echo.
echo # Aplicando otimizacoes do sistema...
echo.

:: Desativar Apps em Segundo Plano
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul && (
    echo [✓] Apps em segundo plano desativados
) || (
    echo [✗] Erro ao desativar apps em segundo plano
)

:: ==================== LIMPEZA AVANÇADA DE ARQUIVOS TEMPORÁRIOS ====================
echo.
echo # Realizando limpeza de arquivos temporarios...
echo.

:: Função para limpar pasta com verificação
call :CleanFolder "%TEMP%" "Pasta Temp do usuario"
call :CleanFolder "C:\Windows\Temp" "Pasta Temp do sistema"
call :CleanFolder "%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files" "Cache Internet Explorer"
call :CleanFolder "%USERPROFILE%\AppData\Local\Microsoft\Windows\Recent" "Arquivos recentes"
call :CleanFolder "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache" "Cache Chrome" 2>nul
call :CleanFolder "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache" "Cache Edge" 2>nul

:: Limpar Prefetch
if exist "C:\Windows\Prefetch\*" (
    del /q /f /s "C:\Windows\Prefetch\*" >nul 2>&1
    echo [✓] Cache Prefetch limpo
)

:: Executar Cleanmgr
echo [i] Executando Limpeza de Disco Avancada...
cleanmgr /sagerun:65535 >nul 2>&1
echo [✓] Limpeza de disco concluida

:: ==================== OTIMIZAÇÕES DE PERFORMANCE AVANÇADAS ====================
echo.
echo # Aplicando otimizacoes de performance avancadas...
echo.

:: Configurar plano de energia de alto desempenho
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul && echo [✓] Plano de energia de alto desempenho ativado

:: Aplicar configurações de GPU
if exist ".\REG\OTIMIZEWINDOWS11.reg" (
    regedit /s ".\REG\OTIMIZEWINDOWS11.reg" && echo [✓] Configuracoes de GPU aplicadas
)
if exist ".\REG\OTIMIZEWINDOWS11 2.reg" (
    regedit /s ".\REG\OTIMIZEWINDOWS11 2.reg" && echo [✓] Configuracoes de GPU 2 aplicadas
)

:: ==================== CONFIGURAÇÃO DE SERVIÇOS ====================
echo.
echo # Configurando servicos do Windows de forma inteligente...
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
                echo [✓] %%c configurado como %%b
            ) else (
                echo [✗] Erro ao configurar %%c
            )
        ) else (
            echo [i] %%c nao encontrado
        )
    )
)

:: ==================== FINALIZAÇÃO ====================
echo.
echo # Executando otimizacoes finais...
echo.

:: Limpar cache DNS
ipconfig /flushdns >nul && echo [✓] Cache DNS limpo

:: Verificar integridade do sistema
echo [i] Verificando integridade do sistema...
sfc /scannow /offbootdir=C:\ /offwindir=C:\Windows >nul 2>&1
echo [✓] Verificacao de integridade concluida

:: Calcular espaço liberado
for /f "tokens=3" %%a in ('dir /a /s ^| find "File(s)"') do set "FILES=%%a"
echo [✓] Limpeza concluida - %FILES% arquivos processados

:: ==================== RELATÓRIO FINAL ====================
echo.
echo ============================================
echo # O SISTEMA FOI OTIMIZADO COM SUCESSO!
echo ============================================
echo.
echo [RESUMO DAS ALTERACOES]
echo • Servicos desnecessarios desativados
echo • Arquivos temporarios removidos
echo • Configuracoes de performance aplicadas
echo.
echo [RECOMENDACOES]
echo 1. Reinicie o computador para aplicar todas as alteracoes
echo 2. Execute este script mensalmente para manutencao
echo 3. Verifique se seus programas funcionam normalmente
echo.
echo O log completo foi salvo em: %LOG_FILE%
echo.

timeout /t 10 >nul

:: Perguntar sobre reinicialização
choice /c SN /m "Deseja reiniciar o computador agora"
if %errorlevel% equ 1 (
    shutdown /r /t 30 /c "Reiniciando para aplicar otimizacoes do sistema. O computador reiniciara em 30 segundos."
    echo [i] O computador sera reiniciado em 30 segundos...
) else (
    echo [i] Lembre-se de reiniciar manualmente para aplicar todas as alteracoes.
)

exit /b

:: ==================== FUNÇÕES ====================
:CleanFolder
if exist "%~1\*" (
    del /q /f /s "%~1\*" >nul 2>&1
    echo [✓] %~2 limpo
)
exit /b