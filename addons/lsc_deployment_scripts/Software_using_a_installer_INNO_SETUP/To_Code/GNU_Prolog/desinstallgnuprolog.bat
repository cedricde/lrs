@echo off

REM reg delete renvoi 0 : succ�s ou 1 : echec

Reg delete "HKLM\SOFTWARE\GNU Prolog" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel GNU Prolog n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\GNU-Prolog"
"unins000.exe" /sp- /verysilent /norestart
cd ..
rmdir "\Program Files\GNU-Prolog" /s /q
echo Desinstallation terminee


:end