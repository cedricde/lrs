@echo off


Reg delete HKLM\SOFTWARE\keepass /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel KeePass n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\KeePass Password Safe"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\KeePass Password Safe"
cd \
rmdir "\Program Files\KeePass Password Safe" /s /q
echo Desinstallation terminee


:end