@echo off


Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\InfraRecorder" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel InfraRecorder n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "C:\Program Files\InfraRecorder"
chmod ugo+rwx *
uninstall.exe /S
cd ..
chmod ugo+rwx "C:\Program Files\InfraRecorder"
cd \
rmdir "\Program Files\InfraRecorder" /s /q
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes\"
rmdir InfraRecorder /s /q
cd \
echo Desinstallation terminee


:end