@echo off


Reg delete HKLM\SOFTWARE\winscp /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel WinSCP n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "C:\Program Files\WinSCP3"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\WinSCP3"
cd \
rmdir "\Program Files\WinSCP3" /s /q
echo Desinstallation terminee


:end