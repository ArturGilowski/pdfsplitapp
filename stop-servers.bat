@echo off
echo Zatrzymywanie serwera AI OCR i interfejsu...

:: Zabij procesy pythona z backendem (uvicorn)
Get-Process python -ErrorAction SilentlyContinue | Where-Object Path -match "pdf-ocr-splitter" | Stop-Process -Force >nul 2>&1
netstat -ano | findstr :8000 > temp.txt
for /f "tokens=5" %%a in (temp.txt) do taskkill /F /PID %%a >nul 2>&1
del temp.txt

:: Zabij procesy portu 3000 (Next.js)
netstat -ano | findstr :3000 > temp.txt
for /f "tokens=5" %%a in (temp.txt) do taskkill /F /PID %%a >nul 2>&1
del temp.txt

echo Wszystkie procesy w tle zatrzymane.
timeout /t 3
