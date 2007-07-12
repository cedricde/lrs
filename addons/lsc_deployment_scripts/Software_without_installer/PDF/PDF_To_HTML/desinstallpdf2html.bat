@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\pdf2html /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel PDF to HTML n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire pdf2html place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\pdf2html"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\pdf2html"
cd \
rmdir "\Program Files\pdf2html" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "PDF to HTML" /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del pdf2html.lnk /q
cd \

echo Desinstallation terminee


:end