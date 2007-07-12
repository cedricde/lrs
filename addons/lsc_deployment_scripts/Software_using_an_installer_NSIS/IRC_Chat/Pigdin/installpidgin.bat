@echo off

REM recherche dans la BDR si le logiciel pidgin est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\pidgin" /v Flag >nul
goto %ERRORLEVEL%

:1

cd 

echo Debut de l'installation
chmod ugo+rx *
"pidgin-2.0.1.exe" /S 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\pidgin" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END