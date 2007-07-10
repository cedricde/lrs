@echo off

Reg QUERY "HKLM\SOFTWARE\Easy Software Products" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
msiexec.exe /i htmldoc-1.8.27.1-windows.msi /qn /norestart
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Easy Software Products" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END
