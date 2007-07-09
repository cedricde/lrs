@echo off

Reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Audacity_is1" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
audacity-win-1.2.6.exe /sp- /verysilent /norestart
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Audacity_is1" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
