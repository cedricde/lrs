@echo off


REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\TightVNC_is1" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel TightVNC n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\TightVNC"
"unins000.exe" /sp- /verysilent /norestart
cd ..
rmdir "\Program Files\TightVNC" /s /q
echo Desinstallation terminee


:end