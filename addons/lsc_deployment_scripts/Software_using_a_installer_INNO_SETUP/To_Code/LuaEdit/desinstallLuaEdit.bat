@echo off

Reg delete HKLM\SOFTWARE\LuaEdit /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel LuaEdit n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\LuaEdit"
"unins000.exe" /sp- /verysilent /norestart
cd \
rmdir "\Program Files\LuaEdit\" /s /q
echo Desinstallation terminee


:end