REM cherche dans C:\ tous les emplacements contenant les fichiers AbiWord
dir c:\ /s /b | find "AbiWord.exe"
dir c:\ /s /b | find "AbiWord 2.4.lnk"



REM on cherche dans la base de registre les informations sur le logiciel, a savoirle nom,le numero de version,l'emplacement d'installation

reg query "HKLM\SOFTWARE\AbiSuite\AbiWord\v2" /v "Start Menu Folder" 

reg query "HKLM\SOFTWARE\AbiSuite\AbiWord\v2" /v "Version" 

reg query "HKLM\SOFTWARE\AbiSuite\AbiWord\v2" /v "Install_Dir" 