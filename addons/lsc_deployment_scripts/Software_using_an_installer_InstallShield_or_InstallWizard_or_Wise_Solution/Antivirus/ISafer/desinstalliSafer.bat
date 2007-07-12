@echo off


Reg delete HKLM\SOFTWARE\iSafer /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel iSafer n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\iSafer"
taskkill /im iSafer.exe /f
taskkill /im iSaferSvr.exe /f
chmod ugo+rwx *
UNWISE.EXE /S /R INSTALL.LOG
cd ..
chmod ugo+rwx "C:\Program Files\iSafer"
cd \
rmdir "\Program Files\iSafer" /s /q
echo Desinstallation terminee


:end