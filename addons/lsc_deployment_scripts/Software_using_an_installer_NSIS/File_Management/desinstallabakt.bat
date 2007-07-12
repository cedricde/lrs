@echo off


Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Abakt.exe" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Abakt n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\Abakt"
chmod ugo+rwx *
uninst.exe /S
cd ..
chmod ugo+rwx "C:\Program Files\Abakt"
cd \
rmdir "\Program Files\Abakt" /s /q

cd \
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Abakt /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Abakt.lnk /q
cd \

echo Desinstallation terminee


:end