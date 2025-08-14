$w = New-Object -comObject WScript.Shell
$d = $w.SpecialFolders("Desktop")
$s = $w.CreateShortcut("$d\ZSKarte.lnk")
$s.TargetPath = "C:\ZSKarte\zskarte.bat"
$s.IconLocation = "C:\ZSKarte\ZSIcon.ico"
$s.Save()
