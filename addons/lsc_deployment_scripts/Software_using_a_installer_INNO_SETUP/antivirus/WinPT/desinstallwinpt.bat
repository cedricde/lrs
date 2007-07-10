@echo off


Reg delete HKLM\SOFTWARE\winPT /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel WinPT n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "C:\Program Files\Windows Privacy Tools"
chmod ugo+rwx *
unins000.exe /silent 
cd ..
chmod ugo+rwx "C:\Program Files\Windows Privacy Tools"
cd \
rmdir "\Program Files\Windows Privacy Tools" /s /q
echo Desinstallation terminee


:end