:: ============== VERIFICAR A INTEGRIDADE DO SISTEMA ==============
sfc/scannow
DISM /Online /Cleanup-Image /RestoreHealth

:: ============= VERIFICAR ERROS NO DISCO ================
chkdsk /f /r

:: ============= LIMPAR O DNS ================
ipconfig /flushdns