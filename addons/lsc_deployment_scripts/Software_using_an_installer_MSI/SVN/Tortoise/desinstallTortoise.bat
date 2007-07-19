@echo off


Reg delete "HKLM\SOFTWARE\TortoiseSVN" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Tortoise SVN  n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd lsc
msiexec /uninstall TortoiseSVN-1.4.4.9706-win32-svn-1.4.4.msi /qn /norestart
cd \
echo Desinstallation terminee


:end