@echo off

REM test dans la BDR si le Flag est à 1( c.a.d ClamWin installé) ou 0 (ClamWin pas installé)

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\ClamWin /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel ClamWin n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd C:\Program Files\ClamWin
"unins000.exe" /verysilent /norestart
echo Desinstallation terminee


:end