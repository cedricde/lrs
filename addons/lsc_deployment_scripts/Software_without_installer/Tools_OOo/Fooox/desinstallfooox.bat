@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\fooox /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Fooox n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire fooox place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\fooox"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\fooox"
cd \
rmdir "\Program Files\fooox" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Fooox /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del fooox001b10.lnk /q
cd "C:\Documents and Settings\All Users\Bureau"
del fooox.lnk /q
cd \

echo Desinstallation terminee


:end