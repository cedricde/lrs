@echo off

Reg delete HKLM\SOFTWARE\ased /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel ASED n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire ased place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\ased"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\ased"
cd \
rmdir "\Program Files\ased" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir ased /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del ased3.0b16.lnk /q
cd \

echo Desinstallation terminee


:end