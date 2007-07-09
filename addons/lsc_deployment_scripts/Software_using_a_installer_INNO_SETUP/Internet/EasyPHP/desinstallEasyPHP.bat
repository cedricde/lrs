@echo off

Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\EasyPHP_is1" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel EasyPHP n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
taskkill /IM "EasyPHP.exe" /F
taskkill /IM "mysqld.exe" /F
taskkill /IM "Apache.exe" /F
cd "C:\Program Files\EasyPHP 2.0b1"
"unins000.exe" /sp- /verysilent /norestart
cd ..
rmdir "\Program Files\EasyPHP 2.0b1" /s /q
echo Desinstallation terminee


:end