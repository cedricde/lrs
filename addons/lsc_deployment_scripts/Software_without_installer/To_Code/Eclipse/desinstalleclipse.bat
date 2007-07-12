@echo off

Reg delete HKLM\SOFTWARE\eclipse /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel eclipse n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire eclipse place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\eclipse"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\eclipse"
cd \
rmdir "\Program Files\eclipse" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir eclipse /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del eclipse.lnk /q
cd \

echo Desinstallation terminee


:end