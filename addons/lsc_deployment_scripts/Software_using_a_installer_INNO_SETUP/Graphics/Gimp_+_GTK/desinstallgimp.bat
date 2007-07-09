@echo off


Reg delete HKLM\SOFTWARE\gimp /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Gimp n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "C:\Program Files\GIMP-2.0"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\GIMP-2.0"
cd \
rmdir "\Program Files\GIMP-2.0" /s /q
echo Desinstallation terminee


:end