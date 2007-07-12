@echo off


Reg delete HKLM\SOFTWARE\notepad++ /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Notepad++ n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\Notepad++"
chmod ugo+rwx *
uninstall.exe /S
cd ..
chmod ugo+rwx "C:\Program Files\Notepad++"
cd \
rmdir "\Program Files\Notepad++" /s /q
echo Desinstallation terminee


:end