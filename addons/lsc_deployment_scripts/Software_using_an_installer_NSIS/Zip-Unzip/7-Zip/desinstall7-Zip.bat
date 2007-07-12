@echo off


Reg delete HKLM\SOFTWARE\7-Zip /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel 7-Zip n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\7-Zip"
chmod ugo+rwx *
uninstall.exe /S
cd ..
chmod ugo+rwx "C:\Program Files\7-Zip"
cd \
rmdir "\Program Files\7-Zip" /s /q
echo Desinstallation terminee


:end