@echo off


Reg delete HKLM\SOFTWARE\qcad /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel QCad n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire QCad place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\QCad"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\QCad"
cd \
rmdir "\Program Files\QCad" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "QCad" /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del qcad.lnk /q
cd \

echo Desinstallation terminee


:end