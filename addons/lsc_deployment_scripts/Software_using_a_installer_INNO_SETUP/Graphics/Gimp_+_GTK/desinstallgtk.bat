@echo off


Reg delete HKLM\SOFTWARE\GTK /v Flag /f 
goto %ERRORLEVEL%

:1

echo L environnement GTK n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "C:\Program Files\Fichiers communs\GTK\2.0\setup"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\Fichiers communs\GTK"
cd \
rmdir "\Program Files\Fichiers communs\GTK" /s /q
echo Desinstallation terminee


:end