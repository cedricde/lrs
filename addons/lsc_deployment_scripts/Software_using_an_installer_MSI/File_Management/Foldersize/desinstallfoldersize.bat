@echo off


Reg delete "HKLM\SOFTWARE\foldersize" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Foldersize  n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd "C:\Program Files\FolderSize"
del info + utilisation foldersize.txt /s
cd \
cd lsc
msiexec /uninstall FolderSize-2.3.msi /qn /norestart
cd \
echo Desinstallation terminee


:end