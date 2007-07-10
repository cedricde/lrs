@echo off


Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GeoShell R4" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel GeoShell n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\Shell"
chmod ugo+rwx *
Uninstall_GeoShell_R4.exe /S
cd ..
chmod ugo+rwx "C:\Program Files\Shell"
cd \
rmdir "\Program Files\Shell" /s /q

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir GeoShell /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del GeoShell.lnk /q
cd \

echo Desinstallation terminee


:end