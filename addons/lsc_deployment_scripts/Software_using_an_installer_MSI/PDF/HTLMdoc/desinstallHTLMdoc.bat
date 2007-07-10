@echo off


Reg delete "HKLM\SOFTWARE\Easy Software Products" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel HTLMdoc  n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
msiexec /uninstall htmldoc-1.8.27.1-windows.msi /qn /norestart
echo Desinstallation terminee


:end