@echo off


REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\inkscape" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Inkscape n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd \
cd "C:\Program Files\Inkscape"
"uninst.exe" /S
echo Desinstallation terminee


:end