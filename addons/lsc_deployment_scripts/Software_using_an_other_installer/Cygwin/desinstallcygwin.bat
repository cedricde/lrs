@echo off


Reg delete "HKLM\SOFTWARE\Cygnus Solutions" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Cygwin n est pas installe
exit 1
GOTO end


:0


REM on supprime le repertoire cygwin
echo debut de la desinstallation
cd \
cd "C:\cygwin"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\cygwin"
cd \
rmdir "\cygwin" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Cygwin /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Cygwin.lnk /q
cd \

reg delete "HKLM\SOFTWARE\Cygnus Solutions" /f

echo Desinstallation terminee


:end