@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\coccinella /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Coccinella n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire Keynote place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\Coccinella"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Coccinella"
cd \
rmdir "\Program Files\Coccinella" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Coccinella /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Coccinella-0.95.16.lnk /q
cd \

echo Desinstallation terminee


:end