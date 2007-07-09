@echo off

REM si le logiciel est deja installe alors le flag cree dans le repertoire Anote de la BDR existe et donc la suppression de ce flag est possible => desinstallation possible


Reg delete HKLM\SOFTWARE\Bouml /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Bouml n est pas installe
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\Bouml"
"unins000.exe" /verysilent /norestart
cd ..
rmdir "\Program Files\Bouml" /s /q
echo Desinstallation terminee


:end