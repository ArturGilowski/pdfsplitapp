$appDir = $PSScriptRoot -replace '\\', '\\\\'

$launcherCode = @"
using System;
using System.Diagnostics;
using System.IO;

namespace Launcher
{
    class Program
    {
        static void Main(string[] args)
        {
            string appDir = @"$appDir";
            string batPath = Path.Combine(appDir, "run-servers.bat");
            
            if (!File.Exists(batPath))
            {
                // Jesli uruchomiono z innego miejsca i nie ma pliku, wyjdz
                return;
            }

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = batPath;
            startInfo.WorkingDirectory = appDir;
            
            // Konfiguracja by aplikacja (run-servers.bat) otwierala sie totalnie ukryta (zadnych czarnych scian txt!)
            startInfo.WindowStyle = ProcessWindowStyle.Hidden;
            startInfo.CreateNoWindow = true;   
            startInfo.UseShellExecute = true;

            try {
                Process.Start(startInfo);
            } catch (Exception ex) {
                // Ignore
            }
        }
    }
}
"@

$desktopPath = [Environment]::GetFolderPath("Desktop")
$exePath = Join-Path $desktopPath "PDF Splitter.exe"
$csPath = Join-Path $env:TEMP "PDFSplitterLauncher.cs"
Set-Content -Path $csPath -Value $launcherCode

# Poszukiwanie darmowego kompilatora C#, ktory zainstalowany jest na kazdym systemie Windows domyslnie:
$csc = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $csc)) {
    $csc = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}

if (Test-Path $csc) {
    & $csc /target:winexe /out:"$exePath" /nologo "$csPath"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Super! Ikonka '[PDF Splitter.exe]' pojawila sie wlasnie na Twoim Pulpicie!" -ForegroundColor Green
    } else {
        Write-Host "Wystapil blad podczas generacji pliku EXE." -ForegroundColor Red
    }
} else {
    Write-Host "Nie znaleziono silnika kompilatora na tym komputerze." -ForegroundColor Red
}
