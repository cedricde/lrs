@echo off

Reg delete "HKLM\SOFTWARE\cream" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel cream n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\vim\vim71"
"uninstall.exe" /S
cd \

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Vim7.1 /s /q

cd \

echo Desinstallation terminee


:end