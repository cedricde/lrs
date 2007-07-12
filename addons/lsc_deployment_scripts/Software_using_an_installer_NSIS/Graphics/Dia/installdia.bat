@echo off

REM recherche dans la BDR si le logiciel Dia est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\dia" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"dia-setup-0.96.1-3.exe" /S 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\dia" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END