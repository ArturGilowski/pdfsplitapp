Set WshShell = CreateObject("WScript.Shell")
' Uruchamia plik .bat, 0 oznacza tryb ukryty (brak czarnego okna cmd)
WshShell.Run chr(34) & "run-servers.bat" & Chr(34), 0
Set WshShell = Nothing
