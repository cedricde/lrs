@echo off

Reg delete HKLM\SOFTWARE\argoUML /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel argoUML n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire argoUML place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\argoUML"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\argoUML"
cd \
rmdir "\Program Files\argoUML" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir argoUML /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del argouml-0.24.lnk /q
cd \

echo Desinstallation terminee


:end