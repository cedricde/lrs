@echo off

Reg delete "HKLM\SOFTWARE\tcltk" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Les logiciels pour TCL TK n sont pas installes
exit 1
GOTO end


:0

REM on supprime le repertoire TCL TK place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\TCL TK"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\TCL TK"
cd \
rmdir "\Program Files\TCL TK" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "TCL TK" /s /q
cd \

echo Desinstallation terminee


:end