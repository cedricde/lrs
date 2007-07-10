@echo off


Reg delete HKLM\SOFTWARE\winmerge /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel WinMerge n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\WinMerge"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\WinMerge"
cd \
rmdir "\Program Files\WinMerge" /s /q
echo Desinstallation terminee


:end