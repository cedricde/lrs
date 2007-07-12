@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\WengoPhone" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel WengoPhone 2.0 beta1 n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd \
cd "C:\Program Files\WengoPhone"
"uninstall.exe" /S
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\WengoPhone"
cd \
rmdir "\Program Files\WengoPhone" /s /q 

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir WengoPhone /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del qtwengophone.lnk /q
cd \

echo Desinstallation terminee


:end