@echo off
echo Zatrzymywanie serwera AI OCR i interfejsu...

:: Zabij procesy pythona z backendem (uvicorn) na porcie 8000
netstat -ano | findstr "LISTENING" | findstr /C:":8000 " > temp.txt
for /f "tokens=5" %%a in (temp.txt) do taskkill /F /PID %%a >nul 2>&1
if exist temp.txt del temp.txt

:: Zabij procesy portu 3000 (Next.js)
netstat -ano | findstr "LISTENING" | findstr /C:":3000 " > temp.txt
for /f "tokens=5" %%a in (temp.txt) do taskkill /F /PID %%a >nul 2>&1
if exist temp.txt del temp.txt

echo Wszystkie procesy w tle zatrzymane.
timeout /t 3
