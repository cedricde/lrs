@echo off

REM recherche dans la BDR si le logiciel Free Pascal est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\Free Pascal" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"fpc-2.1.4.i386-win32.exe" /sp- /verysilent /norestart /dir="C:\Program Files\FPC" 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Free Pascal" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1
:END