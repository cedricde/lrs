@echo off

REM recherche dans la BDR si le logiciel Winpooch est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\Winpooch /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
Winpooch-0.6.6.exe /sp- /verysilent /norestart
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\Winpooch /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END