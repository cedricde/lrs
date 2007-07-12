@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\ooovirg /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel OOovirg n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire ooovirg place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\ooovirg"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\ooovirg"
cd \
rmdir "\Program Files\ooovirg" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir OOovirg /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del OOoVirgTray.lnk /q
cd \

echo Desinstallation terminee


:end