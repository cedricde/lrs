@echo off

REM recherche dans la BDR si le logiciel LuaEdit est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\LuaEdit /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"LESetup.exe" /sp- /verysilent /norestart 
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\LuaEdit /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END