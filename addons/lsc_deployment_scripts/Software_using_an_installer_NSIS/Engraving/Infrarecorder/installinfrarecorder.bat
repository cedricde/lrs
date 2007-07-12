@echo off


Reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\InfraRecorder" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
ir0431_unicode.exe /S
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\InfraRecorder" /v Flag /t REG_DWORD /d "1" /f 
goto END

:0

echo logiciel deja installe
exit 1


:END
