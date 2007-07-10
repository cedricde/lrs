@echo off


REM test dans la BDR si le Flag est à 1( c.a.d OOo  installé) ou 0 (OOo pas installé)

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\OpenOffice.org /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Open Office version 2.2.0 n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
msiexec /uninstall openofficeorg22.msi /qn /norestart
echo Desinstallation terminee


:end