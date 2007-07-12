@echo off

Reg delete "HKLM\SOFTWARE\GNU Fortran 77" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel GNU Fortran 77 n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire G77 place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\G77"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\G77"
cd \
rmdir "\Program Files\G77" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir G77 /s /q
cd \
cd "C:\Documents and Settings\All Users\Bureau"
rmdir G77 /s /q
cd \


echo Desinstallation terminee


:end