@echo off

REM recherche dans la BDR si le logiciel KeePass est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\keepass /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
KeePass-1.07-Setup.exe /sp- /verysilent /norestart
taskkill /im KeePass-1.07-Setup.exe /f

echo Installation terminee.


Reg ADD HKLM\SOFTWARE\keepass /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END