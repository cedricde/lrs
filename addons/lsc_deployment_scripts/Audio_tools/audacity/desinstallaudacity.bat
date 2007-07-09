@echo off


Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Audacity_is1" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Audacity n est pas installe
GOTO end


:0


echo debut de la desinstallation
cd \
cd C:\Program Files\Audacity
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\Audacity"
cd \
rmdir "\Program Files\Audacity" /s /q
echo Desinstallation terminee


:end