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

# Po poprawnej instalacji plik exe pojawia się na pulpicie użytkownika = odpalmy go!
$desktopPath = [Environment]::GetFolderPath("Desktop")
$exePath = Join-Path $desktopPath "PDF Splitter.exe"

if (Test-Path $exePath) {
    Write-Host "Instalacja zakonczona sukcesem! Uruchamianie silnika PDF z pliku " $exePath "..." -ForegroundColor Green
    Start-Process $exePath
} else {
    Write-Host "Cós poszlo nie tak. Środowisko nie wygenerowało pliku PDF Splitter.exe na Twoim pulpicie." -ForegroundColor Red
}
'''''''''''''''''''''
PS C:\Users\magil> $repo = "https://github.com/ArturGilowski/pdfsplitapp.git"
PS C:\Users\magil> $installPath = "$env:LOCALAPPDATA\pdfsplitapp"
PS C:\Users\magil>
PS C:\Users\magil> # Sprawdzenie i zautomatyzowana instalacja Git (wymagane obejscia na licencje w tle)
PS C:\Users\magil> if (!(Get-Command git -ErrorAction SilentlyContinue)) {
>>     Write-Host "Instalowanie środowiska Git..." -ForegroundColor Cyan
>>     winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
>>
>>     # Odswiezenie zmiennej srodowiskowej w locie
>>     $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
>>     if (!(Get-Command git -ErrorAction SilentlyContinue)) {
>>         $env:Path += ";C:\Program Files\Git\cmd"
>>     }
>> }
PS C:\Users\magil>
PS C:\Users\magil> if (!(Test-Path $installPath)) {
>>     New-Item -ItemType Directory -Path $installPath -Force | Out-Null
>> }
PS C:\Users\magil> Set-Location $installPath
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (!(Test-Path ".git")) {
>>     Write-Host "Pobieranie repozytorium..." -ForegroundColor Cyan
>>     git clone $repo .
>> } else {
>>     Write-Host "Aktualizowanie istniejącego folderu..." -ForegroundColor Cyan
>>     git pull
>> }
Aktualizowanie istniejącego folderu...
remote: Enumerating objects: 11, done.
remote: Counting objects: 100% (11/11), done.
remote: Compressing objects: 100% (9/9), done.
remote: Total 9 (delta 4), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (9/9), 4.73 KiB | 284.00 KiB/s, done.
From https://github.com/ArturGilowski/pdfsplitapp
   8beaef5..e1cad0e  main       -> origin/main
Updating 8beaef5..e1cad0e
Fast-forward
 README.md | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (Test-Path ".\install.ps1") {
>>     Write-Host "Rozpoczynam zautomatyzowana instalacje (pythona, noda i tesseract-ocr)." -ForegroundColor Yellow
>>     Write-Host "Zaakceptuj prośbę o uprawnienia administratora w nowym oknie!" -ForegroundColor Yellow
>>
>>     # Budujemy bezwględną ścieżkę do pobranego pliku install.ps1, tak aby system uważał na zmianę katalogów
>>     $installScript = Join-Path $installPath "install.ps1"
>>
>>     # Uruchamiamy od razu PowerShell z uprawnieniami administratora i flagą -Wait
>>     Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$installScript`"" -Verb RunAs -Wait
>> }
Rozpoczynam zautomatyzowana instalacje (pythona, noda i tesseract-ocr).
Zaakceptuj prośbę o uprawnienia administratora w nowym oknie!
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> # Po poprawnej instalacji plik exe pojawia się na pulpicie użytkownika = odpalmy go!
PS C:\Users\magil\AppData\Local\pdfsplitapp> $desktopPath = [Environment]::GetFolderPath("Desktop")
PS C:\Users\magil\AppData\Local\pdfsplitapp> $exePath = Join-Path $desktopPath "PDF Splitter.exe"
PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp> if (Test-Path $exePath) {
>>     Write-Host "Instalacja zakonczona sukcesem! Uruchamianie silnika PDF z pliku " $exePath "..." -ForegroundColor Green
>>     Start-Process $exePath
>> } else {
>>     Write-Host "Cós poszlo nie tak. Środowisko nie wygenerowało pliku PDF Splitter.exe na Twoim pulpicie." -ForegroundColor Red
>> }
Instalacja zakonczona sukcesem! Uruchamianie silnika PDF z pliku  C:\Users\magil\OneDrive\Desktop\PDF Splitter.exe ...
Start-Process : This command cannot be run due to the error: Operacja nie zakończyła się pomyślnie, ponieważ plik zawie
ra wirusa lub potencjalnie niechciane oprogramowanie.
At line:3 char:5
+     Start-Process $exePath
+     ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [Start-Process], InvalidOperationException
    + FullyQualifiedErrorId : InvalidOperationException,Microsoft.PowerShell.Commands.StartProcessCommand

PS C:\Users\magil\AppData\Local\pdfsplitapp>
PS C:\Users\magil\AppData\Local\pdfsplitapp>
