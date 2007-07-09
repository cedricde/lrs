REM cherche dans C:\ tous les emplacements contenant les fichiers A Note
dir c:\ /s /b | find "jedit.jar"
dir c:\ /s /b | find "jEdit.lnk"



REM on cherche dans la base de registre les informations sur le logiciel, a savoirle nom,le numero de version,l'emplacement d'installation

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\jEdit_is1" /v DisplayName 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\jEdit_is1" /v "Inno Setup: Setup Version" 

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\jEdit_is1" /v InstallLocation 