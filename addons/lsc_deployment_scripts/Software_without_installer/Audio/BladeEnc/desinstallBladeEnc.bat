@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\BladeEnc /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel BladeEnc n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire BladeEnc place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\BladeEnc"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\BladeEnc"
cd \
rmdir "\Program Files\BladeEnc" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir BladeEnc /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del BladeEnc.lnk /q
cd \

echo Desinstallation terminee


:end