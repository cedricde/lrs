REM cherche dans C:\ tous les emplacements contenant les fichiers A Note
dir c:\ /s /b | find "GeoShell.exe"
dir c:\ /s /b | find "GeoShell.lnk"



REM on cherche dans la base de registre les informations sur le logiciel, a savoirle nom,le numero de version,l'emplacement d'installation

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GeoShell R4" /v DisplayName 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GeoShell R4" /v "DisplayVersion" 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GeoShell R4" /v InstallLocation 