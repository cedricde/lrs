@echo off


Reg QUERY "HKLM\SOFTWARE\netbeans" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"jdk-6u1-nb-5_5_1-win-ml.exe" -silent
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\netbeans" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END