REM cherche dans C:\ tous les emplacements contenant les fichiers A Note
dir c:\ /s /b | find "firefox.exe"
dir c:\ /s /b | find "Mozilla Firefox.lnk"



REM on cherche dans la base de registre les informations sur le logiciel, a savoirle nom,le numero de version,l'emplacement d'installation

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (2.0.0.4)" /v DisplayName 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (2.0.0.4)" /v "DisplayVersion" 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (2.0.0.4)" /v InstallLocation 