@echo off

REM recherche dans la BDR si le logiciel ClamWin est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\ClamWin /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"clamwin-0.90.2.1-setup.exe" /sp- /verysilent /norestart 
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\ClamWin /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe

:END
