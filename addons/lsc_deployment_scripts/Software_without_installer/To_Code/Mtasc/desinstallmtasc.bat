@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\mtasc /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel MTASC n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire mtasc-1.13 place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\mtasc-1.13"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\mtasc-1.13"
cd \
rmdir "\Program Files\mtasc-1.13" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir mtasc-1.13 /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del mtasc.lnk /q
del "utilisation de mtasc.lnk" /q
cd \

echo Desinstallation terminee


:end