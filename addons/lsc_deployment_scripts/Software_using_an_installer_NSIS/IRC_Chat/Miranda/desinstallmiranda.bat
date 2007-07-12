@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\miranda" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Miranda n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd \
cd "C:\Program Files\Miranda IM"
"Uninstall.exe" /S
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Miranda IM"
cd \
rmdir "\Program Files\Miranda IM" /s /q 
echo Desinstallation terminee


:end