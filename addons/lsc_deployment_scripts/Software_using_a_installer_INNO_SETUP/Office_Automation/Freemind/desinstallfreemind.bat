@echo off


Reg delete HKLM\SOFTWARE\freemind /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Freemind n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\FreeMind"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\FreeMind"
cd \
rmdir "\Program Files\FreeMind" /s /q
echo Desinstallation terminee


:end