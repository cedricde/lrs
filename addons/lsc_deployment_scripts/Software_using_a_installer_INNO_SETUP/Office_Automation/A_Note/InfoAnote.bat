REM cherche dans C:\ tous les emplacements contenant les fichiers A Note
dir c:\ /s /b | find "A Note.exe"
dir c:\ /s /b | find "A Note.lnk"



REM on cherche dans la base de registre les informations sur le logiciel, a savoirle nom,le numero de version,l'emplacement d'installation

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\A Note_is1" /v DisplayName 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\A Note_is1" /v "Inno Setup: Setup Version" 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\A Note_is1" /v InstallLocation 