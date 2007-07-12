@echo off

Reg delete HKLM\SOFTWARE\netbeans /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Netbeans n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\netbeans-5.5.1\_uninst"
"uninstaller.exe" -silent
cd \
rmdir "\Program Files\netbeans-5.5.1" /s /q

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "NetBeans 5.5.1" /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del NetBeans 5.5.1.lnk /q
cd \

echo Desinstallation terminee


:end