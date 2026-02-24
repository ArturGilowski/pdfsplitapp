@echo off
set START_DIR=%~dp0

:: Upewnijmy sie ze stare procesy z wczoraj nie blokuja portu 3000, inaczej Next.js pojdzie na port 3001 i Edge go nie znajdzie!
echo Zatrzymywanie ew. wczesniejszych instancji...
call "%START_DIR%stop-servers.bat"

:: Uruchamianie Backend (Python API)
echo Uruchamianie serwera AI OCR...
cd /d "%START_DIR%backend"
start /b cmd /c ".\venv\Scripts\activate && python main.py"

:: Oczekiwanie by backend wstał
timeout /t 3 /nobreak >nul

:: Uruchamianie Frontend (Next.js)
echo Przygotowywanie interfejsu graficznego...
cd /d "%START_DIR%frontend"
start /b cmd /c "npm run dev"

:: Oczekiwanie na uruchomienie frontendu - Pierwsze budowanie (Turbopack) moze potrwac nawet kilkanascie sekund!
echo Oczekiwanie az serwer na porcie 3000 zglosi gotowosc...
:wait_loop
netstat -ano | findstr "LISTENING" | findstr ":3000" >nul
if %errorlevel% neq 0 (
    timeout /t 2 /nobreak >nul
    goto wait_loop
)

:: Uruchomienie okna "Aplikacji" przez Edge 
start msedge --app=http://localhost:3000 --app-id=pdfocrsplitter

:: Utrzymanie otwartego glownego, ukrytego okna skryptu, by przypiete do niego powloki cmd.exe pythona i npm w tle mogly trwac bez konca
pause >nul
exit
