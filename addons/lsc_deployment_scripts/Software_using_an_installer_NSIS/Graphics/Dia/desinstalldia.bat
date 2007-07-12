@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\dia" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Dia n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd \
cd "C:\Program Files\Dia"
"dia-0.96.1-3-uninstall.exe" /S
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Dia"
cd \
rmdir "\Program Files\Dia" /s /q 
echo Desinstallation terminee


:end