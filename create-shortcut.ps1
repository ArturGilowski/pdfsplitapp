$WshShell = New-Object -comObject WScript.Shell
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$Shortcut = $WshShell.CreateShortcut("$DesktopPath\PDF AI Splitter.lnk")

$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = """C:\Users\magil\OneDrive\Dokumenty\agents\pdf-ocr-splitter\hidden-launcher.vbs"""
$Shortcut.WorkingDirectory = "C:\Users\magil\OneDrive\Dokumenty\agents\pdf-ocr-splitter"
# Use a built-in Windows icon 
$Shortcut.IconLocation = "shell32.dll, 274"
$Shortcut.Description = "Włącz lokalną bazę OCR i program do dzielenia PDF-ów"
$Shortcut.Save()
Write-Host "Skrót na Pulpicie stworzony."
