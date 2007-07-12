@echo off

REM recherche dans la BDR si le logiciel aMSN est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\aMSN" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"amsn-0.97RC1-1-windows-installer.exe" /S 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\aMSN" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END