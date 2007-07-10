@echo off


Reg delete HKLM\SOFTWARE\pdfcreator /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel PDFcreator  n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
msiexec /uninstall zPDFCreator-0_9_3-AD_DeploymentPackage-WithoutToolbar.msi /qn /norestart
echo Desinstallation terminee


:end