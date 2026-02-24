@echo off
NET SESSION >nul 2>&1
if %errorLevel% == 0 (
    echo Uprawnienia administratora potwierdzone.
) else (
    echo Zadam uprawnien administratora (UAC)...
    PowerShell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

title Instalator PDF Splitter
echo ===================================================
echo   Rozpoczynam instalacje aplikacji PDF Splitter...
echo ===================================================

cd /d "%~dp0"
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"

echo.
echo Wcisnij dowolny klawisz, aby zakonczyc...
pause >nul
