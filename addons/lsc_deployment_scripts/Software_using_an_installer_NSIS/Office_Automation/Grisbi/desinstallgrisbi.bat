@echo off

REM reg delete renvoi 0 : succ�s ou 1 : echec

Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GRISBI" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Grisbi n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd C:\lsc
"uninstall.exe" /S
cd \
echo Desinstallation terminee


:end