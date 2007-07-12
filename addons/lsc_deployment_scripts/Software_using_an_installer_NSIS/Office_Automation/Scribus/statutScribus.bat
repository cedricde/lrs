REM cherche dans C:\ tous les emplacements contenant les fichiers Scribus
dir c:\ /s /b | find "Scribus.exe"
dir c:\ /s /b | find "Scribus 1.3.3.9.lnk"



REM on cherche dans la base de registre les informations sur le logiciel, a savoir le numero de version et le nom

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Scribus 1.3.3" /v DisplayName 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Scribus 1.3.3" /v DisplayVersion 