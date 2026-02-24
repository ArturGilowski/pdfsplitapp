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


++++++++++++++++

PS C:\Users\magil\AppData\Local\pdfsplitapp> $repo = "https://github.com/ArturGilowski/pdfsplitapp.git"
PS C:\Users\magil\AppData\Local\pdfsplitapp> $installPath = "$env:LOCALAPPDATA\pdfsplitapp"
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Get-Command git -ErrorAction SilentlyContinue)) {
>>     winget install --id Git.Git -e --source winget
>>     $env:Path += ";C:\Program Files\Git\cmd"
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Test-Path $installPath)) {
>>     New-Item -ItemType Directory -Path $installPath -Force | Out-Null
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> Set-Location $installPath
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Test-Path ".git")) {
>>     git clone $repo .
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (Test-Path ".\Setup.bat") {
>>     Start-Process ".\Setup.bat" -Wait
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (Test-Path ".\PDFsplitter.exe") {
>>     Start-Process ".\PDFsplitter.exe"
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> $repo = "https://github.com/ArturGilowski/pdfsplitapp.git"
PS C:\Users\magil\AppData\Local\pdfsplitapp> $installPath = "$env:LOCALAPPDATA\pdfsplitapp"
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Get-Command git -ErrorAction SilentlyContinue)) {
>>     winget install --id Git.Git -e --source winget
>>     $env:Path += ";C:\Program Files\Git\cmd"
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Test-Path $installPath)) {
>>     New-Item -ItemType Directory -Path $installPath -Force | Out-Null
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> Set-Location $installPath
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Test-Path ".git")) {
>>     git clone $repo .
>> }
Cloning into '.'...
remote: Enumerating objects: 556, done.
remote: Counting objects: 100% (556/556), done.
remote: Compressing objects: 100% (374/374), done.
remote: Total 556 (delta 179), reused 546 (delta 174), pack-reused 0 (from 0)
Receiving objects: 100% (556/556), 13.12 MiB | 8.60 MiB/s, done.
Resolving deltas: 100% (179/179), done.
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (Test-Path ".\Setup.bat") {
>>     Start-Process ".\Setup.bat" -Wait
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (Test-Path ".\PDFsplitter.exe") {
>>     Start-Process ".\PDFsplitter.exe"
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp> $repo = "https://github.com/ArturGilowski/pdfsplitapp.git"
PS C:\Users\magil\AppData\Local\pdfsplitapp> $installPath = "$env:LOCALAPPDATA\pdfsplitapp"
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> # Sprawdzenie i zautomatyzowana instalacja Git (wymagane obejscia na licencje w tle)
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Get-Command git -ErrorAction SilentlyContinue)) {
>>     Write-Host "Instalowanie środowiska Git..." -ForegroundColor Cyan
>>     winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
>>
>>     # Odswiezenie zmiennej srodowiskowej w locie
>>     $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
>>     if (!(Get-Command git -ErrorAction SilentlyContinue)) {
>>         $env:Path += ";C:\Program Files\Git\cmd"
>>     }
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Test-Path $installPath)) {
>>     New-Item -ItemType Directory -Path $installPath -Force | Out-Null
>> }
PS C:\Users\magil\AppData\Local\pdfsplitapp> Set-Location $installPath
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Test-Path ".git")) {
>>     Write-Host "Pobieranie repozytorium..." -ForegroundColor Cyan
>>     git clone $repo .
>> } else {
>>     Write-Host "Aktualizowanie istniejącego folderu..." -ForegroundColor Cyan
>>     git pull
>> }
Pobieranie repozytorium...
Cloning into '.'...
remote: Enumerating objects: 559, done.
remote: Counting objects: 100% (559/559), done.
remote: Compressing objects: 100% (377/377), done.
remote: Total 559 (delta 181), reused 546 (delta 174), pack-reused 0 (from 0)
Receiving objects: 100% (559/559), 13.12 MiB | 2.47 MiB/s, done.
Resolving deltas: 100% (181/181), done.
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (Test-Path ".\Setup.bat") {
>>     Write-Host "Uruchamianie instalatora aplikacji krok 1... Zaakceptuj pojawiające się uprawnienia UAC" -ForegroundColor Yellow
>>
>>     # Uruchamiamy od razu z uprawnieniami administratora; tak zeby nasz proces mogl zaczekac (-Wait) na instalatora.
>>     Start-Process -FilePath "cmd.exe" -ArgumentList "/c `".\Setup.bat`"" -Verb RunAs -Wait
>> }
Uruchamianie instalatora aplikacji krok 1... Zaakceptuj pojawiające się uprawnienia UAC
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> # Po poprawnej instalacji plik exe pojawia się na pulpicie użytkownika = odpalmy go!
PS C:\Users\magil\AppData\Local\pdfsplitapp> $desktopPath = [Environment]::GetFolderPath("Desktop")
PS C:\Users\magil\AppData\Local\pdfsplitapp> $exePath = Join-Path $desktopPath "PDF Splitter.exe"
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (Test-Path $exePath) {
>>     Write-Host "Uruchamianie silnika PDF..." -ForegroundColor Green
>>     Start-Process $exePath
>> } else {
>>     Write-Host "Cós poszlo nie tak. Nie znaleziono pliku PDF Splitter.exe na pulpicie docelowym." -ForegroundColor Red
>> }

