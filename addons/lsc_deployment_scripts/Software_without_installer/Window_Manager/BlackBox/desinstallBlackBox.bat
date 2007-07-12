echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\BlackBox /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel BlackBox n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire BlackBox 4 Win 0.0.92 place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\BlackBox 4 Win 0.0.92"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\BlackBox 4 Win 0.0.92"
cd \
rmdir "\Program Files\BlackBox 4 Win 0.0.92" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir BlackBox /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Blackbox.lnk /q
cd \

echo Desinstallation terminee


:end