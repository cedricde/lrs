@echo off

Reg delete HKLM\SOFTWARE\batik-1.7 /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel batik-1.7 n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire batik-1.7 place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\batik-1.7"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\batik-1.7"
cd \
rmdir "\Program Files\batik-1.7" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir batik-1.7 /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del batik.lnk /q
cd \

echo Desinstallation terminee


:end