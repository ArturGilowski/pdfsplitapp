win -> terminal -> ctrl + v (poniższy skrypt) -> enter 
powinna stworzyc się ikonka o nazwie "PDF Splitter" na pulpicie 
uruchomienie zajmie kilka sekund 

Obsługa aplikacji:
- wrzucamy PDF który chcemy podzielic 
- klikamy przycisk analizuj
- sprawdzamy podzial jesli jest zly to poprawiamy 
- akceptujemy 
- pobieramy zip

KOD PSHW: 
-------------------------------------------------------------------------------------------------------------------------------


  $repoZip = "https://github.com/ArturGilowski/pdfsplitapp/archive/refs/heads/main.zip"
$installPath = "$env:LOCALAPPDATA\pdfsplitapp"
$zipPath = "$env:TEMP\pdfsplitapp.zip"

Write-Host "Rozpoczynam instalacje w: $installPath" -ForegroundColor Cyan

if (!(Test-Path $installPath)) {
New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}

Set-Location $installPath

Write-Host "Pobieranie paczki aplikacji bez logowania..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $repoZip -OutFile $zipPath

Write-Host "Rozpakowywanie plikow..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force
Copy-Item -Path "$env:TEMP\pdfsplitapp-main\*" -Destination $installPath -Recurse -Force
Remove-Item -Path "$env:TEMP\pdfsplitapp-main" -Recurse -Force
Remove-Item -Path $zipPath -Force

if (Test-Path ".\install.ps1") {
Write-Host "Rozpoczynam zautomatyzowana instalacje srodowisk uruchomieniowych..." -ForegroundColor Yellow
Write-Host ">>> ZAAKCEPTUJ PROSBE O UPRAWNIENIA ADMINISTRATORA W NOWYM OKNIE! <<<" -ForegroundColor Yellow

$installScript = Join-Path $installPath "install.ps1"

$args = '-NoExit -NoProfile -ExecutionPolicy Bypass -File "' + $installScript + '"'
Start-Process -FilePath "powershell.exe" -ArgumentList $args -Verb RunAs -Wait
}

$desktopPath = [Environment]::GetFolderPath("Desktop")
$exePath = Join-Path $desktopPath "PDF Splitter.lnk"

if (Test-Path $exePath) {
Write-Host "Instalacja zakonczona mega sukcesem! Odpalam okno..." -ForegroundColor Green
Start-Process $exePath
} else {
Write-Host "Cós poszlo nie tak z instalatorem - brak PDF Splitter.lnk" -ForegroundColor Red
}  



-------------------------------------------------------------------------------------------------------------------------------

Artur Gilowski
