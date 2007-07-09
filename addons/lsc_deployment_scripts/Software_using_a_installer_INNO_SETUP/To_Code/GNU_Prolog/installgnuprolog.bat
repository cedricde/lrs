@echo off

REM recherche dans la BDR si le logiciel GNU Prolog est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\GNU Prolog" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"setup-gprolog-1.3.0.exe" /sp- /verysilent /norestart /dir="C:\Program Files\GNU-Prolog" 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\GNU Prolog" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END