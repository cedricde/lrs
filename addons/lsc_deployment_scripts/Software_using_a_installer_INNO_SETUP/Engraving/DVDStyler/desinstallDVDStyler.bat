@echo off


Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DVDStyler_is1" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel DVDStyler n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "C:\Program Files\DVDStyler"
chmod ugo+rwx *
unins000.exe /silent 
cd ..
chmod ugo+rwx "C:\Program Files\DVDStyler"
cd \
rmdir "\Program Files\DVDStyler" /s /q
echo Desinstallation terminee


:end