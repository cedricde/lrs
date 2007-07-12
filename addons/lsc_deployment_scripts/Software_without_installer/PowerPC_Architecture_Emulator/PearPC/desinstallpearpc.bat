@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\pearpc /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel pearpc 0.4 n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire pearpc 0.4 place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\pearpc 0.4"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\pearpc 0.4"
cd \
rmdir "\Program Files\pearpc 0.4" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "pearpc 0.4" /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del ppc.lnk /q
cd \

echo Desinstallation terminee


:end