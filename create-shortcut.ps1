$WshShell = New-Object -comObject WScript.Shell
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$Shortcut = $WshShell.CreateShortcut("$DesktopPath\PDF Splitter.lnk")

$vbsPath = Join-Path $PSScriptRoot "hidden-launcher.vbs"

$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = """$vbsPath"""
$Shortcut.WorkingDirectory = $PSScriptRoot

# Use a built-in Windows icon 
$Shortcut.IconLocation = "shell32.dll, 274"
$Shortcut.Description = "Włącz lokalną bazę OCR i program do dzielenia PDF-ów"
$Shortcut.Save()

Write-Host "Gotowe! Skrót 'PDF Splitter' znalazl się na Twoim Pulpicie!" -ForegroundColor Green
