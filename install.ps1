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
$pythonReady = $false

try {
    # Uruchamiamy python omijajac systemowe bledy aplikacyjne, ErrorAction pomoze jesli pliku zupelnie brak, a przekierowanie 2>&1 zamaskuje sam blad Store
    $ver = & python --version 2>&1
    if ($LASTEXITCODE -eq 0 -and $ver -match "Python") {
        $pythonReady = $true
    }
} catch {
    # Ignorujemy błędy, w tym ten strasznie wyglądający czerwony z aliasem
}

if (!$pythonReady) {
    Write-Host "Python nie zostal znaleziony wg systemu lub blokuje go alias. Instaluje za pomoca winget..." -ForegroundColor Yellow
    winget install --id Python.Python.3.11 -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
    
    # Odswiezenie zmiennych srodowiskowych by skrypt zauwazyl Pythona bez koniecznosci restartu instalatora
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "Python jest prawidlowo zainsalowany." -ForegroundColor Green
}

# Check/Install Node.js
Write-Host "Sprawdzanie Node.js..."
$nodeReady = $false
if (Get-Command "node" -ErrorAction SilentlyContinue) {
    # Check if installed node is at least v20.9.0 
    $nodeVerStr = node -v
    if ($nodeVerStr -match "v(\d+)\.(\d+)\.") {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        
        # Next.js 16.1.6 and its ESLint plugins require Node >= 20.9.0
        if (($major -gt 20) -or ($major -eq 20 -and $minor -ge 9)) {
            $nodeReady = $true
        }
    }
}

if (!$nodeReady) {
    Write-Host "Node.js (npm) nie zostal znaleziony lub jest zbyt stary (wymagane v20.9+). Aktualizuje przez winget..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS -e --silent --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "Node.js jest prawidlowo zainstalowany." -ForegroundColor Green
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
