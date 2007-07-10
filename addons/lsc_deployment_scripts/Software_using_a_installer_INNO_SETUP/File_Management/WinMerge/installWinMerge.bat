@echo off

Reg QUERY "HKLM\SOFTWARE\winmerge" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
WinMerge-2.6.8-Setup.exe /sp- /verysilent /norestart
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\winmerge" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
