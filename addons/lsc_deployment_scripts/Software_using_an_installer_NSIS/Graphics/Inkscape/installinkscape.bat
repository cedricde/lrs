@echo off

REM recherche dans la BDR si le logiciel Inkscape est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\inkscape" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"Inkscape-0.45.1-1.win32.exe" /S 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\inkscape" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END