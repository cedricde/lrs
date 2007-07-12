@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\Mozilla\Mozilla Sunbird 0.3.1" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Sunbird n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\Mozilla Sunbird\uninstall"
"uninst.exe" /S
chmod ugo+rwx *
cd ..
cd ..
chmod ugo+rwx "C:\Program Files\Mozilla Sunbird"
cd \
rmdir "\Program Files\Mozilla Sunbird" /s /q 
echo Desinstallation terminee


:end