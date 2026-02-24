Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
batPath = scriptDir & "\run-servers.bat"

Set WshShell = CreateObject("WScript.Shell")
' Uruchamia plik .bat z absolutnej ścieżki obok siebie, 0 oznacza tryb ukryty
WshShell.Run chr(34) & batPath & Chr(34), 0
Set WshShell = Nothing
