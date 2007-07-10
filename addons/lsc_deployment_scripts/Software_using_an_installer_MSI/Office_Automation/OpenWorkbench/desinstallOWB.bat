@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\Niku /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Open Workbench n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
msiexec /uninstall "Open Workbench.msi" /qn /norestart

REM on supprime le repertoire Open Workbench place dans Program Files 
cd \
cd "C:\Program Files\Open Workbench"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Open Workbench"
cd \
rmdir "\Program Files\Open Workbench" /s /q 

echo Desinstallation terminee


:end