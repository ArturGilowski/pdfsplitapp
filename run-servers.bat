@echo off
set START_DIR=%~dp0

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

:: Oczekiwanie na uruchomienie frontendu
timeout /t 5 /nobreak >nul

:: Uruchomienie okna "Aplikacji" przez Edge lub Chrome
:: --app ucina paski kart i adresu URL by wyglądało jak program na komputerze
start msedge --app=http://localhost:3000 --app-id=pdfocrsplitter

exit
