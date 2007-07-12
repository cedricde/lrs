@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\pidgin" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel pidgin n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd \
cd "C:\Program Files\Pidgin"
"pidgin-uninst.exe" /S
cd ..
chmod ugo+rwx "C:\Program Files\Pidgin"
cd \
rmdir "\Program Files\Pidgin" /q 

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
del Pidgin.lnk /q
cd \
echo Desinstallation terminee


:end