@echo off

REM si le logiciel est deja installe alors le flag cree dans le repertoire Anote de la BDR existe et donc la suppression de ce flag est possible => desinstallation possible


REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\A Note_is1" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel A Note n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\A Note"
"unins000.exe" /verysilent /norestart
cd ..
rmdir "\Program Files\A Note" /s /q
echo Desinstallation terminee


:end