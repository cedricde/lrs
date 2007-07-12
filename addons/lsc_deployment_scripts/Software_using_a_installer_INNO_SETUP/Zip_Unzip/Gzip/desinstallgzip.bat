@echo off

Reg delete "HKLM\SOFTWARE\GnuWin32" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Gzip n est pas installe
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\GnuWin32\uninstall"
"unins000.exe" /sp- /verysilent /norestart
cd ..
cd ..
rmdir "\Program Files\GnuWin32" /s /q
echo Desinstallation terminee


:end