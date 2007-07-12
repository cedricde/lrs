REM cherche dans C:\ tous les emplacements contenant les fichiers Grisbi
dir c:\ /s /b | find "grisbi.exe"
dir c:\ /s /b | find "Grisbi 0.5.9.lnk"
dir c:\ /s /b | find "grisbi.lnk"


REM on cherche dans la base de registre les informations sur le logiciel, a savoir le numero de version et le nom

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GRISBI" /v DisplayName 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GRISBI" /v DisplayVersion 