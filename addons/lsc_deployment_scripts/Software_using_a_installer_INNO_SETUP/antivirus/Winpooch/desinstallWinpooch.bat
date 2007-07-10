@echo off


Reg delete HKLM\SOFTWARE\Winpooch /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Winpooch n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
taskkill /IM "Winpooch.exe" /F
cd "Program Files\Winpooch"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\Winpooch"
cd \
rmdir "\Program Files\Winpooch" /s /q
echo Desinstallation terminee


:end