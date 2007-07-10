@echo off

REM recherche dans la BDR si le logiciel putty est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\putty /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
putty-0.60-installer.exe /sp- /verysilent /norestart
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\putty /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
