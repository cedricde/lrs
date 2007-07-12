@echo off


Reg delete "HKLM\SOFTWARE\Axon Data" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel AxCrypt n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "C:\Program Files\Axon Data\AxCrypt"
chmod ugo+rwx *
AxCryptU.exe /S
cd \
chmod ugo+rwx "C:\Program Files\Axon Data"
cd \
rmdir "\Program Files\Axon Data" /s /q
echo Desinstallation terminee


:end