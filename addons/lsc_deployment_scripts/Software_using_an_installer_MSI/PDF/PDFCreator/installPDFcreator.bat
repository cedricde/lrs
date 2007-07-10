@echo off

Reg QUERY HKLM\SOFTWARE\pdfcreator /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
msiexec.exe /i zPDFCreator-0_9_3-AD_DeploymentPackage-WithoutToolbar.msi /qn /norestart
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\pdfcreator /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END
