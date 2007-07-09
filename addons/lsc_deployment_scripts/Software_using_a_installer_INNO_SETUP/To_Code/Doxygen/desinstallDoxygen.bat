@echo off

Reg delete HKLM\SOFTWARE\doxygen /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel doxygen n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\doxygen\system"
"unins000.exe" /verysilent /norestart
cd \
rmdir "\Program Files\doxygen\" /s /q
echo Desinstallation terminee


:end