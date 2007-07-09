@echo off

Reg delete "HKLM\SOFTWARE\Free Pascal" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Free Pascal n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\FPC"
"unins000.exe" /sp- /verysilent /norestart
cd ..
rmdir "\Program Files\FPC" /s /q
echo Desinstallation terminee


:end