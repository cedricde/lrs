@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\exodus" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Exodus n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd \
cd "C:\Program Files\Exodus"
"Uninstall.exe" /S
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Exodus"
cd \
rmdir "\Program Files\Exodus" /s /q 

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Exodus /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Exodus.lnk /q
cd \
echo Desinstallation terminee


:end



