@echo off


Reg delete HKLM\SOFTWARE\wpclipart /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Wpclipart n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "C:\Program Files\wpclipart"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\wpclipart"
cd \
rmdir "\Program Files\wpclipart" /s /q
echo Desinstallation terminee


:end