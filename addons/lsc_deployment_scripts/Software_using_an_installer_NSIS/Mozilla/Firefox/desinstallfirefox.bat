@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\Mozilla\Mozilla Firefox 2.0.0.4" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Firefox n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\Mozilla Firefox\uninstall"
"helper.exe" /S
chmod ugo+rwx *
cd ..
cd ..
chmod ugo+rwx "C:\Program Files\Mozilla Firefox"
cd \
rmdir "\Program Files\Mozilla Firefox" /s /q 
echo Desinstallation terminee


:end