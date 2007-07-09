@echo off


Reg delete HKLM\SOFTWARE\jEdit /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel jEdit n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\jEdit"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\jEdit"
cd \
rmdir "\Program Files\jEdit" /s /q
echo Desinstallation terminee


:end