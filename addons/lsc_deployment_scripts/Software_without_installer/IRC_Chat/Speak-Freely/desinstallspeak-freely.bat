@echo off


Reg delete HKLM\SOFTWARE\speak-freely /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Speak-freely n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire speak-freely place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\speak-freely"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\speak-freely"
cd \
rmdir "\Program Files\speak-freely" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Speak-freely /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Speakfre.lnk /q
cd \

echo Desinstallation terminee


:end