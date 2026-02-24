# pdfsplitapp
 
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

if (Test-Path ".\Setup.bat") {
    Write-Host "Uruchamianie instalatora aplikacji krok 1... Zaakceptuj pojawiające się uprawnienia UAC" -ForegroundColor Yellow
    
    # Uruchamiamy od razu z uprawnieniami administratora; tak zeby nasz proces mogl zaczekac (-Wait) na instalatora.
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `".\Setup.bat`"" -Verb RunAs -Wait
}

# Po poprawnej instalacji plik exe pojawia się na pulpicie użytkownika = odpalmy go!
$desktopPath = [Environment]::GetFolderPath("Desktop")
$exePath = Join-Path $desktopPath "PDF Splitter.exe"

if (Test-Path $exePath) {
    Write-Host "Uruchamianie silnika PDF..." -ForegroundColor Green
    Start-Process $exePath
} else {
    Write-Host "Cós poszlo nie tak. Nie znaleziono pliku PDF Splitter.exe na pulpicie docelowym." -ForegroundColor Red
}
