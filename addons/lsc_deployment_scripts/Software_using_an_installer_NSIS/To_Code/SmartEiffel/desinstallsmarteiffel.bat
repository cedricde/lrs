@echo off


Reg delete HKLM\SOFTWARE\RubyInstaller /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Ruby n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\ruby"
chmod ugo+rwx *
uninstall.exe /S
cd ..
chmod ugo+rwx "C:\Program Files\ruby"
cd \
rmdir "\Program Files\ruby" /s /q
echo Desinstallation terminee


:end