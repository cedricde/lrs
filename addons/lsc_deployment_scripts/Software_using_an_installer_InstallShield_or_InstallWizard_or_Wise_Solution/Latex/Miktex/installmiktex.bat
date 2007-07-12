@echo off


Reg QUERY "HKLM\SOFTWARE\miktex" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
basic-miktex-2.6.2704.exe --unattended
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\miktex" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END