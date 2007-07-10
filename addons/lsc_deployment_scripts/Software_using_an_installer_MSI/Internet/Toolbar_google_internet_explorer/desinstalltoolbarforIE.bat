@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\Google\Google Toolbar" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Google Toolbar n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
msiexec /uninstall "GoogleToolbarInstaller4.0.0.002.msi" /qn /norestart

REM on supprime le repertoire Google place dans Program Files 
cd \
cd "C:\Program Files\Google"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Google"
cd \
rmdir "\Program Files\Google" /s /q 

echo Desinstallation terminee


:end