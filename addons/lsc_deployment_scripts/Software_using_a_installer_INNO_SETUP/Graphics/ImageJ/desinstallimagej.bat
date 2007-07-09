@echo off


Reg delete HKLM\SOFTWARE\imagej /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel ImageJ n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\ImageJ"
chmod ugo+rwx *
unins000.exe /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\ImageJ"
cd \
rmdir "\Program Files\ImageJ" /s /q
echo Desinstallation terminee


:end