@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\PDF Blender" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel PDF Blender n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd C:\lsc
"uninstall.exe" /S
cd \

REM le desinstallateur n efface pas completement le repertoire PDF Blender situé dans Program Files
cd "C:\Program Files\PDF Blender"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\PDF Blender"
cd \
rmdir "\Program Files\PDF Blender" /s /q 


cd \
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir PDFBlender /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del PDFBlender.lnk /q
cd \

echo Desinstallation terminee


:end