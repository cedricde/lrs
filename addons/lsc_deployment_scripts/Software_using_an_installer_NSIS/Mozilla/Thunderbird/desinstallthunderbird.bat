@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\Mozilla\Mozilla Thunderbird 2.0.0.0" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Thunderbird version 2.0.0.0 n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\Mozilla Thunderbird\uninstall"
"helper.exe" /S
chmod ugo+rwx *
cd ..
cd ..
chmod ugo+rwx "C:\Program Files\Mozilla Thunderbird"
cd \
rmdir "\Program Files\Mozilla Thunderbird" /s /q 
echo Desinstallation terminee


:end