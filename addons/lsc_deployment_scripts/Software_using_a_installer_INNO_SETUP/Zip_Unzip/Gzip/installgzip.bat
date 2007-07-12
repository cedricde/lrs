@echo off

Reg QUERY "HKLM\SOFTWARE\GnuWin32" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"gzip-1.3.12-setup.exe" /sp- /verysilent /norestart 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\GnuWin32" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END