@echo off

REM recherche dans la BDR si le logiciel Python 2.2.3 est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\Python" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
msiexec /i python-2.5.1.msi /qn /norestart
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Python" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END