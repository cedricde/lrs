@echo off

Reg QUERY "HKLM\SOFTWARE\freemind" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
FreeMind-Windows-Installer-0_8_0-max.exe /sp- /verysilent /norestart
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\freemind" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
