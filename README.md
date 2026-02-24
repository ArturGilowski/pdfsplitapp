$repo = "https://github.com/ArturGilowski/pdfsplitapp.git"
$installPath = "$env:LOCALAPPDATA\pdfsplitapp"

# Sprawdzenie i zautomatyzowana instalacja Git (wymagane obejscia na licencje w tle)
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Instalowanie środowiska Git..." -ForegroundColor Cyan
    winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
    
    # Odswiezenie zmiennej srodowiskowej w locie
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        $env:Path += ";C:\Program Files\Git\cmd"
    }
}

if (!(Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}
Set-Location $installPath

if (!(Test-Path ".git")) {
    Write-Host "Pobieranie repozytorium..." -ForegroundColor Cyan
    git clone $repo .
} else {
    Write-Host "Aktualizowanie istniejącego folderu..." -ForegroundColor Cyan
    git pull
}

if (Test-Path ".\install.ps1") {
    Write-Host "Rozpoczynam zautomatyzowana instalacje (pythona, noda i tesseract-ocr)." -ForegroundColor Yellow
    Write-Host "Zaakceptuj prośbę o uprawnienia administratora w nowym oknie!" -ForegroundColor Yellow
    
    # Budujemy bezwględną ścieżkę do pobranego pliku install.ps1, tak aby system uważał na zmianę katalogów
    $installScript = Join-Path $installPath "install.ps1"
    
    # Uruchamiamy od razu PowerShell z uprawnieniami administratora i flagą -Wait
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$installScript`"" -Verb RunAs -Wait
}

# Po poprawnej instalacji skrót .lnk pojawia się na pulpicie użytkownika = odpalmy go!
$desktopPath = [Environment]::GetFolderPath("Desktop")
$exePath = Join-Path $desktopPath "PDF Splitter.lnk"

if (Test-Path $exePath) {
    Write-Host "Instalacja zakonczona sukcesem! Uruchamianie silnika PDF z pliku " $exePath "..." -ForegroundColor Green
    Start-Process $exePath
} else {
    Write-Host "Cós poszlo nie tak. Środowisko nie wygenerowało pliku PDF Splitter.lnk na Twoim pulpicie." -ForegroundColor Red
}


