# pdfsplitapp
 
$repo = "https://github.com/ArturGilowski/pdfsplitapp.git"
$installPath = "$env:LOCALAPPDATA\pdfsplitapp"

if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    winget install --id Git.Git -e --source winget
    $env:Path += ";C:\Program Files\Git\cmd"
}

if (!(Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}

Set-Location $installPath

if (!(Test-Path ".git")) {
    git clone $repo .
}

if (Test-Path ".\Setup.bat") {
    Start-Process ".\Setup.bat" -Wait
}

if (Test-Path ".\PDF splitter.exe") {
    Start-Process ".\PDF splitter.exe"
}
