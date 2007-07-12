@echo off


Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FileZilla Server" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel FileZilla n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd "C:\Program Files\FileZilla Server"
chmod ugo+rwx *
start /wait Uninstall.exe /S
taskkill /IM "Au_.exe" /F
cd\
chmod ugo+rwx "C:\Program Files\FileZilla Server"
rmdir "\Program Files\FileZilla Server" /s /q

cd\
cd "C:\Documents and Settings\All Users\Bureau"
del "FileZilla server.lnk" /q
cd \

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "FileZilla Server" /s /q
cd \

echo Desinstallation terminee


:end