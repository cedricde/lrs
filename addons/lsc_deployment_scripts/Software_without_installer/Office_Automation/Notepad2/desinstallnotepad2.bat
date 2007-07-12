@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\notepad2 /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Notepad2 n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire notepad2 place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\notepad2"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\notepad2"
cd \
rmdir "\Program Files\notepad2" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Notepad2 /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Notepad2.lnk /q
cd \

echo Desinstallation terminee


:end