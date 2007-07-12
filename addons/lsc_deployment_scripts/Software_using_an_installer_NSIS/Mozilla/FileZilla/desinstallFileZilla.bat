@echo off


Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FileZilla" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel FileZilla n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation



cd "C:\Program Files\FileZilla"
chmod ugo+rwx *
start /wait uninstall.exe /S
taskkill /IM "Au_.exe" /F
cd\
chmod ugo+rwx "C:\Program Files\FileZilla"
rmdir "\Program Files\FileZilla" /s /q

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir FileZilla /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del FileZilla.lnk /q
cd \

:end