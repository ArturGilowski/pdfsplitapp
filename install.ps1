$ErrorActionPreference = "Stop"

Write-Host "Rozpoczynam konfiguracje srodowiska PDF Splitter..." -ForegroundColor Cyan

# Check/Install Tesseract
Write-Host "Sprawdzanie Tesseract OCR..."
if (!(Test-Path "C:\Program Files\Tesseract-OCR\tesseract.exe")) {
    Write-Host "Tesseract OCR nie znaleziono. Rozpoczynam pobieranie i instalacje. Moze to chwile potrwac..." -ForegroundColor Yellow
    $installerPath = "$env:TEMP\tesseract-setup.exe"
    Invoke-WebRequest -Uri "https://github.com/UB-Mannheim/tesseract/releases/download/v5.4.0.20240606/tesseract-ocr-w64-setup-5.4.0.20240606.exe" -OutFile $installerPath
    
    # Instalacja w trybie cichym
    $process = Start-Process -FilePath $installerPath -ArgumentList "/SILENT", "/DIR=`"C:\Program Files\Tesseract-OCR`"" -Wait -NoNewWindow -PassThru
    if ($process.ExitCode -eq 0) {
        Write-Host "Tesseract OCR zostal zainstalowany." -ForegroundColor Green
    } else {
        Write-Host "Uwaga: Instalacja Tesseract OCR zwrocila kod $($process.ExitCode)." -ForegroundColor Red
    }
} else {
    Write-Host "Tesseract OCR juz zainstalowany." -ForegroundColor Green
}

# Refresh Environment Variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check/Install Python
Write-Host "Sprawdzanie Pythona..."
if (!(Get-Command "python" -ErrorAction SilentlyContinue)) {
    Write-Host "Python nie zostal znaleziony. Instaluje przez winget..." -ForegroundColor Yellow
    winget install --id Python.Python.3.11 -e --silent --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "Python juz zainsalowany." -ForegroundColor Green
}

# Check/Install Node.js
Write-Host "Sprawdzanie Node.js..."
if (!(Get-Command "npm" -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js (npm) nie zostal znaleziony. Instaluje przez winget..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS -e --silent --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "Node.js juz zainstalowany." -ForegroundColor Green
}

# Setup Backend
Write-Host "Konfiguracja Backend (Python)..." -ForegroundColor Cyan
Set-Location -Path "$PSScriptRoot\backend"
if (!(Test-Path "venv")) {
    Write-Host "Tworzenie srodowiska wirtualnego..."
    python -m venv venv
}
Write-Host "Instalowanie pakietow Pythona..."
.\venv\Scripts\python.exe -m pip install -r requirements.txt | Out-Null
Write-Host "Pakiety Pythona zainstalowane." -ForegroundColor Green

# Setup Frontend
Write-Host "Konfiguracja Frontend (Node.js)..." -ForegroundColor Cyan
Set-Location -Path "$PSScriptRoot\frontend"
Write-Host "Instalowanie modulow NPM..."
npm install --no-fund --no-audit | Out-Null
Write-Host "Moduly NPM zainstalowane." -ForegroundColor Green

# Generate desktop shortcut / launcher
Set-Location -Path $PSScriptRoot
Write-Host "Generowanie Skrotu do aplikacji na pulpicie..." -ForegroundColor Cyan
PowerShell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\create-shortcut.ps1"

Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Gotowe! Aplikacja zostala w pelni zainstalowana." -ForegroundColor Green
Write-Host "Mozesz pominac czarne okienka podczas startu klikajac w swoja nowa ikone aplikacji." -ForegroundColor Green
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
