@echo off

REM reg delete renvoi 0 : succ�s ou 1 : echec

Reg delete HKLM\SOFTWARE\picophone /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel picophone n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire Picophone place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\Picophone"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Picophone"
cd \
rmdir "\Program Files\Picophone" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Picophone /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del PicoPhone164.lnk /q
cd \

echo Desinstallation terminee


:end