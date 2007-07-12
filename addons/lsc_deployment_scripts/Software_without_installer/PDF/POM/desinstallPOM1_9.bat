@echo off


Reg delete HKLM\SOFTWARE\pom-1_9 /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel POM version 1.9 n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire pom-1_9 place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\pom-1_9"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\pom-1_9"
cd \
rmdir "\Program Files\pom-1_9" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "pom 1.9" /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del pom.lnk /q
cd \

echo Desinstallation terminee


:end