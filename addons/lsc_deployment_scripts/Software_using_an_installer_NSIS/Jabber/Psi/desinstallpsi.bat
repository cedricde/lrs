@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\psi" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Psi n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd \
cd "C:\Program Files\Psi"
"Uninstall.exe" /S
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Psi"
cd \
rmdir "\Program Files\Psi" /s /q 

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Psi /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del psi.lnk /q
cd \


echo Desinstallation terminee


:end