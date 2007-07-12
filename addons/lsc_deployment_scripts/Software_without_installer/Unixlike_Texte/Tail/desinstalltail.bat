@echo off


Reg delete HKLM\SOFTWARE\tail /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Tail 4.2.12 n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire Tail 4.2.12 place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\Tail 4.2.12"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Tail 4.2.12"
cd \
rmdir "\Program Files\Tail 4.2.12" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "Tail 4.2.12" /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Tail.lnk /q
cd \

echo Desinstallation terminee


:end